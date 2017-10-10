Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_admin_insights'
  s.version     = '1.2.2'
  s.summary     = 'Add some reporting to admin section. '
  s.description = 'Track what product being viewed, what being purchased. Who are consistant buyers etc.'
  s.required_ruby_version = '>= 2.1.0'

  s.author    = ['Nimish Mehta', 'Tanmay Sinha', 'Nimish Gupta', '+ Vinsol Team']
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com/spreecommerce-admin-insights'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_development_dependency 'capybara', '~> 2.4'
  s.add_development_dependency 'coffee-rails', '>= 4.0.0'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker', '~> 2.2.0'
  s.add_development_dependency 'mysql2', '~> 0.4.0'
  s.add_development_dependency 'pg', '~> 0.18.0'
  s.add_development_dependency 'rspec-rails',  '~> 3.1'
  s.add_development_dependency 'sass-rails', '~> 5.0.0'
  s.add_development_dependency 'chartkick', '~> 1.4.0'
  s.add_development_dependency 'selenium-webdriver', '~> 2.52.0'
  s.add_development_dependency 'simplecov', '~> 0.11.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.6.2'
  s.add_development_dependency 'solidus_backend', ['>= 1.0', '< 3']
  s.add_dependency 'wicked_pdf', '~> 1.0.6'
  s.add_dependency 'wkhtmltopdf-binary', '~> 0.9.9.3'
end
