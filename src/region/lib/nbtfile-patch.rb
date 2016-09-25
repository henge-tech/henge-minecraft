module NBTFile
  # Copy from NBTFile.load(io)
  def self.load_uncompressed(io)
    root = {}
    stack = [root]

    # self.tokenize(io) do |token|
    self.tokenize_uncompressed(io) do |token|
      case token
      when Tokens::TAG_Compound
        value = {}
      when Tokens::TAG_List
        value = []
      when Tokens::TAG_End
        stack.pop
        next
      else
        value = token.value
      end

      stack.last[token.name] = value

      case token
      when Tokens::TAG_Compound, Tokens::TAG_List
        stack.push value
      end
    end

    root.first
  end
end
