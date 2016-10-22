class MCACircle
  def self.load(circles_dir, list_file)
    mca_circles = {}
    open(list_file) do |f|
      f.each_line do |line|
        line.chomp!
        data = line.split(/\t/)
        circle = {}
        circle[:id] = data[0]
        xyz = data[1..3].map(&:to_i)
        circle[:pattern] = data[4]

        loc  = MCAFile.coords_to_mca(xyz[0], xyz[2] + 1, xyz[1] - 1)

        circle[:loc] = loc
        circle[:words] = YAML.load(File.read(File.join(circles_dir, circle[:pattern] + '.yml')))

        mca_circles[loc[:mcafile]] ||= []
        mca_circles[loc[:mcafile]] << circle
      end
    end
    mca_circles
  end
end
