module CaptureOutput
  def capture_stderr
    previous, $stderr = $stderr, StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = previous
  end

  def capture_stdout
    previous, $stdout = $stdout, StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = previous
  end
end

RSpec.configure do |config|
  config.include CaptureOutput
end
