namespace :cdf do
  namespace :db do

    desc 'Load the seed data from db/seeds.rb'
    task :seed => 'db:abort_if_pending_migrations' do
      seed_file = File.join(Rails.root, 'cdf', 'db', 'seeds.rb')
      load(seed_file) if File.exist?(seed_file)
    end

  end
end