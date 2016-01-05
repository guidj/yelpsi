def usage():

    print("{$APPDIR}/filter.py inputFile outputDir cities"
          "\nWhere:"
          "\n\tdataDir: JSON file data for cities, with cities as keys"
          "\n\toutputDir: directory to store output file"
          "\n\tcities: comma separateed list of cities to extract from file")


def extract_cities(inp, out, cities):

    import os.path
    import json

    with open(inp, 'r') as fp:
        source = json.load(fp)

    data = {}
    mark = {city: False for city in cities}

    for city, payload in source.items():

        if city in cities:
            data[city] = payload
            mark[city] = True

    outpath = os.path.join(out, "selected_data_summary.json")
    with open(outpath, 'w') as fp:
        json.dump(data, fp)

    print("Data written to", outpath)

    if any([not found for _, found in mark.items()]):
        print("Din't find: {0}".format([city for city, found in mark.items() if found is False]))

if __name__ == "__main__":

    import sys

    if len(sys.argv) < 3:
        usage()

    inp = sys.argv[1]
    out = sys.argv[2]
    cities = sys.argv[3].split(",")

    print("Source:", inp)
    print("Target:", out)
    print("Cities", cities)

    extract_cities(inp, out, cities)




