ALL = ['Block_Mapper']

class Block_Mapper:
    """
    process data after receiving a block of records
    """
    def __init__(self, blk_sz):
        self.blk_sz = blk_sz
        self.data = []
        self.sz = 0
    
    def __call__(self, records):
        for row in records:
            self.data.append(self.parse(row[1]))
            self.sz += 1
            if self.sz >= self.blk_sz:
                for key, value in self.process():
                    yield key, value
                self.data = []
                self.sz = 0
        if self.sz > 0:
            for key, value in self.process():
                yield key, value
        for key, value in self.close():
            yield key, value

    def parse(self, row):
        return row

    def process(self):
        return iter([])
    
    def close(self):
        return iter([])

class Block_Dumper(Block_Mapper):
    """
    collect all data and send
    """
    def __init__(self):
        Block_Mapper.__init__(self, float('inf'))
    def parse(self, row):
        return row[1]
    def close(self):
        yield 0, self.data
