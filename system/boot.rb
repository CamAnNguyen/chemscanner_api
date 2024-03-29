# frozen_string_literal: true

# This file is responsible for loading all configuration files.

require 'pry'
require 'securerandom'
require 'dry-validation'
require 'chem_scanner'
require 'rdkit_chem'
require 'inchi-gem'

require_relative 'application'

# Register automatically application classess and the external dependencies from the /system/boot folder.
Application.finalize!

# Add exsiting Logger instance to DB.loggers collection.
# Application['database'].loggers << Application['logger']

# Freeze internal data structures for the Database instance.
Application['database'].freeze unless Application.env == 'development'
