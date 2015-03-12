function save_data(data, dir)

  datatype = [data.filename, '_data'];
  eval([datatype num2str(data.order) '= data']);

  fname = [dir, data.filename, '_results', num2str(data.order)];
  mkdir(fname);
  save(fullfile(fname, [datatype, num2str(data.order)]), [datatype, num2str(data.order)]);

end

