def usage():

    print("{$APPDIR}/parser.py inputpath outpath"
          "\nWhere:"
          "\tinputpath: dir with Yelp! data files"
          "\toutputpath: dir for output")


def parse_review_aggregation_by_city_by_category(datadir, outputpath):

    import os
    import json
    import collections

    if not os.path.isdir(datadir):
        raise RuntimeError(
            "{0} is not a directory".format(datadir)
        )

    if not os.path.isdir(outputpath):
        os.makedirs(outputpath)

    with open(os.path.join(datadir, 'yelp_academic_dataset_business.json'), 'r') as fp:

        data = collections.defaultdict(dict)
        categories = set()
        businesses = collections.defaultdict(dict)

        for line in fp:
            payload = json.loads(line)

            # if payload['open']:

            city = payload['city']

            for category in payload['categories']:
                categories.add(category)

                if category not in data[city]:
                    data[city][category] = collections.defaultdict(float)

            businesses[payload['business_id']] = {
                'city': city,
                'latitude': payload['latitude'],
                'longitude': payload['longitude'],
                'categories': payload['categories'],
                'stars': payload['stars']
            }

    with open(os.path.join(datadir, 'yelp_academic_dataset_review.json'), 'r') as fp:

        for line in fp:

            payload = json.loads(line)

            business_id = payload['business_id']
            business = businesses[business_id]

            for category in business['categories']:
                data[business['city']][category]['stars'] += payload['stars']
                data[business['city']][category]['reviews_count'] += 1

    with open(os.path.join(datadir, 'yelp_academic_dataset_checkin.json'), 'r') as fp:

        for line in fp:

            payload = json.loads(line)

            business_id = payload['business_id']
            business = businesses[business_id]

            for checkin in payload['checkin_info']:
                hour, date = checkin.split('-')

                for category in business['categories']:

                    if 'checkin' not in data[business['city']][category]:
                        data[business['city']][category]['checkin'] = collections.defaultdict(dict)

                    if date not in data[business['city']][category]['checkin']:
                        data[business['city']][category]['checkin'][date] = collections.defaultdict(int)

                    data[business['city']][category]['checkin'][date][hour] += 1

    for city in data:

        for category in data[city]:
            try:
                data[city][category]['average_stars'] = \
                    round(data[city][category]['stars']/data[city][category]['reviews_count'], 1)
            except ZeroDivisionError:
                data[city][category]['average_stars'] = 0

            del data[city][category]['stars']

            if 'checkin' in data[city][category]:

                for day in data[city][category]['checkin']:
                    data[city][category]['checkin'][day]['summary'] = sum([c for _, c in data[city][category]['checkin'][day].items()])

                data[city][category]['checkin']['summary'] = sum([c['summary'] for _, c in data[city][category]['checkin'].items()])


    with open(os.path.join(outputpath, 'reviews_summary.json'), 'w') as fp:
        json.dump(data, fp, indent=4)

    print(
            "Read {0} cities".format(len(data))
    )


if __name__ == "__main__":

    import sys

    if len(sys.argv) < 3:
        usage()

    inp = sys.argv[1]
    out = sys.argv[2]

    parse_review_aggregation_by_city_by_category(inp, out)
