def usage():
    print("{$APPDIR}/parser.py inputpath outpath"
          "\n\nWhere:"
          "\n\tinputpath: dir with Yelp! data files"
          "\n\toutputpath: dir for output")


def correct_city_name(name, state):
    # TODO: use an algorithm to do this? (close geo-coordinates, diff in space of letter casing)

    if name in ['De Forest', 'Deforest', 'De Forest']:
        return 'DeForest'
    elif name in ['Mc Farland', 'Mcfarland', 'McFarland']:
        return 'McFarland'
    elif name == "London" and state == "EDH":
        return "Edinburgh"
    else:
        return name


def central_geo_coordinate(latitudes, longitudes):

    import math

    if len(latitudes) != len(longitudes):
        raise RuntimeError('Latitudes and longitudes lists have different length')

    if len(latitudes) == 1:
        return {'lat': latitudes[0], 'long': longitudes[0]}

    x, y, z, = 0, 0, 0

    for latitude, longitude in zip(latitudes, longitudes):

        lat = latitude * math.pi / 180
        long = longitude * math.pi / 180

        x += math.cos(lat) * math.cos(long)
        y += math.cos(lat) * math.sin(long)
        z += math.sin(lat)

    total = len(latitudes)

    x, y, z = x/total, y/total, z/total

    central_longitude = math.atan2(y, x)
    central_sqrt = math.sqrt(x * x + y * y)
    central_latitude = math.atan2(z, central_sqrt)

    return {'lat': central_latitude*180/math.pi, 'long': central_longitude*180/math.pi}


def parse_activity_data(datadir, outputpath):

    import os
    import json
    import collections
    import csv

    if not os.path.isdir(datadir):
        raise RuntimeError(
            "{0} is not a directory".format(datadir)
        )

    if not os.path.isdir(outputpath):
        os.makedirs(outputpath)

    data = collections.defaultdict(dict)
    businesses = collections.defaultdict(dict)
    cities = []

    with open(os.path.join(datadir, 'yelp_academic_dataset_business.json'), 'r') as fp,\
        open(os.path.join(outputpath, 'businesses.csv'), 'w') as busfp:

        buswriter = csv.writer(busfp)

        buswriter.writerow(['id', 'name', 'city', 'address', 'latitude', 'longitude', 'stars', 'categories'])

        for line in fp:
            payload = json.loads(line)
            city = correct_city_name(payload['city'], payload['state'])

            for category in payload['categories']:

                if category not in data[city]:
                    data[city][category] = collections.defaultdict(float)

            businesses[payload['business_id']] = {
                'city': city,
                'latitude': payload['latitude'],
                'longitude': payload['longitude'],
                'categories': payload['categories'],
                'stars': payload['stars']
            }

            cities.append((city, payload['latitude'], payload['longitude']))

            buswriter.writerow([payload['business_id'], payload['name'],
                                city, payload['full_address'].replace('\n', ', '),
                                payload['latitude'], payload['longitude'],
                                payload['stars'],
                                ', '.join(payload['categories'])])

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
                    round(data[city][category]['stars'] / data[city][category]['reviews_count'], 1)
            except ZeroDivisionError:
                data[city][category]['average_stars'] = 0

            del data[city][category]['stars']

            if 'checkin' in data[city][category]:

                for day in data[city][category]['checkin']:
                    data[city][category]['checkin'][day]['summary'] = sum(
                        [c for _, c in data[city][category]['checkin'][day].items()])

                data[city][category]['checkin']['summary'] = sum(
                    [c['summary'] for _, c in data[city][category]['checkin'].items()])

    # city, category, review data (avg stars, #reviews)
    with open(os.path.join(outputpath, 'reviews.csv'), 'w') as fp:
        writer = csv.writer(fp)
        writer.writerow(["city", "category", "average_stars", "reviews_count"])

        for city in data:

            for category in data[city]:
                writer.writerow([city,
                                 category,
                                 data[city][category]['average_stars'],
                                 data[city][category]['reviews_count']])

    with open(os.path.join(outputpath, 'checkin.csv'), 'w') as fp:
        writer = csv.writer(fp)
        writer.writerow(["city", "category", "day", "hour", "checkin_count"])

        for city in data:

            for category in data[city]:

                if 'checkin' in data[city][category]:
                    for day in data[city][category]['checkin']:
                        if day != "summary":
                            for hour in data[city][category]['checkin'][day]:
                                if hour != "summary":
                                    writer.writerow([
                                        city,
                                        category,
                                        day,
                                        hour,
                                        data[city][category]['checkin'][day][hour]
                                    ])

    with open(os.path.join(outputpath, 'cities.csv'), 'w') as fp:
        city_set = set([x[0] for x in cities])

        writer = csv.writer(fp)
        writer.writerow(['city', 'latitude', 'longitude'])

        for city in city_set:

            latitudes, longitudes = [x[1] for x in cities if x[0] == city], [x[2] for x in cities if x[0] == city]

            central_coordinates = central_geo_coordinate(latitudes, longitudes)
            writer.writerow([city, central_coordinates['lat'], central_coordinates['long']])

    print(
        "Read {0} cities".format(len(data))
    )


if __name__ == "__main__":

    import sys

    if len(sys.argv) < 3:
        usage()

    inp = sys.argv[1]
    out = sys.argv[2]

    parse_activity_data(inp, out)
