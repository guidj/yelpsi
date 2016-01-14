"""
Convert data into csv files
"""


def usage():

    print("{$APPDIR}/tables.py inputfile outpath"
          "\n\nWhere:"
          "\n\tinputfile: JSON file data for cities, with cities as keys"
          "\n\toutputpath: dir for output")


def writetables(inp, datadir):

    import os
    import json
    import csv

    if not os.path.isdir(datadir):
        raise RuntimeError(
            "{0} is not a directory".format(datadir)
        )

    if not os.path.isdir(datadir):
        os.makedirs(datadir)

    with open(inp, 'r') as fp:
        data = json.load(fp)

    file = os.path.join(datadir, "reviews.csv")

    # city, category, review data (avg stars, #reviews)
    with open(file, 'w') as fp:
        writer = csv.writer(fp)
        writer.writerow(["city", "category", "average_stars", "reviews_count"])

        for city in data:

            for category in data[city]:

                writer.writerow([city,
                                 category,
                                 data[city][category]['average_stars'],
                                 data[city][category]['reviews_count']])

    file = os.path.join(datadir, "checkin.csv")

    with open(file, 'w') as fp:
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

    #TODO: checkin table, 1 file per city?

if __name__ == "__main__":

    import sys

    if len(sys.argv) < 3:
        usage()

    inp = sys.argv[1]
    out = sys.argv[2]

    writetables(inp, out)