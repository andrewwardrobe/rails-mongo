# frozen_string_literal: true

desc 'Load Test env'

namespace :test do
  task :start_containers do
    ids = []
    container_options = {
      'Image' => 'mongo',
      'HostConfig' => {
        'PortBindings' => { '27017/tcp' => [{ 'HostPort' => '27017' }] }
      }

    }

    container = Docker::Container.create container_options
    container.start

    ids << container.id
    File.open(Rails.root.join('tmp', 'containers.pid'), 'w') { |file| file.write ids.to_yaml }
  end

  def stop_containers
    ids = YAML.load_file(Rails.root.join('tmp', 'containers.pid'))
    ids.each do |id|
      container = Docker::Container.get(id)
      container.stop
      container.delete
    end
  end

  task :stop_containers do
    stop_containers
  end

  # Trick to make this alway run after pec
  task :post_spec_cleanup do
    at_exit { stop_containers }
  end
  Rake::Task['spec'].enhance ['test:post_spec_cleanup', 'test:start_containers']
end

