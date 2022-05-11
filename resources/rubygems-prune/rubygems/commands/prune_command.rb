require 'rubygems/command'
require 'fileutils'

class Gem::Commands::PruneCommand < Gem::Command
  def initialize
    super('prune', 'Prune installed gems of any specs, tests or examples.', :dry_run => false)

    add_option('--[no-]dry-run', 'Do not remove files, only report would would be removed') do |value, options|
      options[:dry_run] = value
    end
  end

  def execute
    file_count = Gem::Specification.map { |gem| prune_gem(gem) }.reduce(0, :+)

    if options[:dry_run]
      say "\nWould have removed #{file_count} files"
    else
      say "\nRemoved #{file_count} files"
    end
  end

  def prune_gem(gem)
    say "Checking #{gem.name}-#{gem.version}..."

    ['spec', 'test', 'examples', 'features'].map { |dir| prune_gem_dir(gem, dir) }.reduce(0, :+)
  end

  def prune_gem_dir(gem, dir)
    path = File.join(gem.full_gem_path, dir)

    return 0 if gem.require_paths.include?(dir)
    return 0 unless File.directory?(path)

    file_count = Dir.glob(File.join(path, '**', '*')).length

    if options[:dry_run]
      say "  Would have removed #{path}"
    else
      FileUtils.remove_entry_secure(path)
    end

    file_count
  end
end
