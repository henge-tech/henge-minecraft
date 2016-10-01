#
# NBTFile patch
#
module NBTFile
  def self.tokenize(io, &block)
    tokenize_uncompressed(io, &block)
  end

  def self.emit(io, &block) #:yields: emitter
    emit_uncompressed(io, &block)
  end
end
