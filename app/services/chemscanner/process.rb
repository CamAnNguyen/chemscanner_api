# frozen_string_literal: true

require 'chem_scanner'

# ChemScanner wrapper lib
module Chemscanner
  # Post and pre-process for each ChemScanner file
  module Process
    # Process cdx
    def self.cdx_process(doc)
      cdx = ChemScanner::Cdx.new
      cdx.read(doc.path)
      cdx
    end

    # Process cdxml
    def self.cdxml_process(doc)
      cdxml = ChemScanner::Cdxml.new
      cdxml.read(doc.path)
      cdxml
    end
  end
end
