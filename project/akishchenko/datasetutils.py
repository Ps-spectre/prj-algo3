import csv

class CsvStats:
    def __init__(self, fn):
        self.fn = fn
        with open(fn) as csvfile:
            reader = csv.DictReader(csvfile)
            self.total = 0
            self.uniqueGroup = {}
            for row in reader:
                self.total += 1
                cluster = row['cluster']
                if cluster not in self.uniqueGroup:
                    self.uniqueGroup[cluster] = 1
                else:
                    self.uniqueGroup[cluster] += 1

    def __str__(self):
        valMin = 1 << 32
        valMax = -1
        avg = 0
        for k, v in self.uniqueGroup.items():
            valMin = min(valMin, v)
            valMax = max(valMax, v)
            avg += v

        avg /= len(self.uniqueGroup)
        return "file: {0}\n\t total files: {1}, unique groups: {2}\n\t in group, min: {3}, max: {4}, avg: {5:.2f}\n".format(self.fn, self.total, len(self.uniqueGroup), valMin, valMax, avg)


if __name__ == '__main__':
    fname = 'results/correct.result.csv'
    stats = CsvStats(fname)
    print(stats)
