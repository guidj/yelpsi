def business_geo_data(inp, out):

    import json
    import csv

    with open(inp, 'r') as ifp, open(out, 'w') as ofp:

        writer = csv.writer(ofp)

        writer.writerow(['category', 'id', 'name', 'address', 'city', 'latitude', 'longitude', 'stars'])

        for line in ifp:
            payload = json.loads(line)

            for category in payload['categories']:

                writer.writerow([category, payload['business_id'], payload['name'],
                                 payload['full_address'].replace('\n', ', '), payload['city'],
                                 payload['latitude'], payload['longitude'],
                                 payload['stars']])


if __name__ == '__main__':

    import sys

    inp = sys.argv[1]
    out = sys.argv[2]

    business_geo_data(inp, out)


