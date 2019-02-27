# Capistrano: Pinned Releases

📌 Pin and unpin capistrano releases. Pinned releases don't get deleted during cleanup. 

✋ **Capistrano 3.0+ only**.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-pinned_releases'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install capistrano-pinned_releases

## Usage

The extension provides following tasks, all under the `deploy:pinned` namespace.

1. **`list`**: List all currently pinned releases:
 
        deploy:pinned:list

    This prints a comma separated list of currently pinned releases:
    
        ** Execute deploy:pinned:list
        20190220192205, 20190225190753

2. **`pin`**: Pin a given release: 

        cap production deploy:pinned:pin RELEASE_NAME=20190220192205
        
    without the `RELEASE_NAME` environment variable, it pins the current release:
    
        cap production deploy:pinned:pin

3. **`unpin`**: Unpin a given release:

        deploy:pinned:unpin RELEASE_NAME=20190220192205

    without the `RELEASE_NAME` environment variable, it pins the current release:
    
        deploy:pinned:unpin

These tasks can be run individually, but they're far more useful when used during the capistrano release lifecycle:

        after 'sidekiq:restart', 'deploy:pinned:pin'
        
Or, as a part of other tasks:

```ruby
rake my_task: :environment do
  if capture(:some_command_on_server, :arg1, :arg2)
    invoke 'deploy:pinned:pin'
  else
    invoke 'deploy:pinned:unpin'
  end
end

# etc.
```

⚠️ This extension overrides the default `deploy:cleanup` task, in order to prevent releases from getting deployed. If you have an extension that also overrides the default behavior on `deploy:cleanup`, then this extension won't work for you. To work around, make sure you are not calling

```ruby
Rake::Task["deploy:cleanup"].clear_actions
```
anywhere within your code.


## Development

Please fork your copy, and do all your work on a appropriately named branch. After checking out the repo, run `bin/setup` to install dependencies.

## Contributing

Bug reports and pull requests are welcome!
