require "rake"
require "stringio"
require "tempfile"

RSpec.describe "hubspot rake tasks", type: :rake do
  let(:hapikey) { "demo" }

  describe "hubspot:dump_properties" do
    it "writes the class properties and groups to the given file" do
      VCR.use_cassette("dump_contact_properties_and_groups") do
        file = Tempfile.new ""

        invoke_rake_task("hubspot:dump_properties", ["contact", file, hapikey])

        result = JSON.parse(File.read(file))

        expect(result.count).to be > 0
        expect(result['groups'].count).to be > 0
        expect(result['properties'].count).to be > 0
      end
    end

    it "prints a deprecation warning" do
      VCR.use_cassette("dump_contact_properties_and_groups") do
        file = Tempfile.new ""

        output = capture_stderr do
          invoke_rake_task("hubspot:dump_properties", ["contact", file, hapikey])
        end

        expect(output).to include("hubspot:dump_properties is deprecated")
      end
    end

    context "given an unknown class" do
      it "raises an error" do
        file = Tempfile.new ""

        expected_error_msg = ':kind must be either "contact" or "deal"'

        expect do
          invoke_rake_task(
            "hubspot:dump_properties",
            ["unknown_class", file, hapikey]
          )
        end.to raise_error(ArgumentError, expected_error_msg)
      end
    end
  end

  describe "hubspot:restore_properties" do
    context "when the class properties match the existing properties" do
      it "should not need to make any changes" do
        VCR.use_cassette("restore_contact_properties_and_groups") do
          file = build_file_with_matching_properties("contact")

          results = capture_stdout do
            invoke_rake_task(
              "hubspot:restore_properties",
              ["contact", file, hapikey]
            )
          end

          expect(results).not_to include("Created: ")
          expect(results).not_to include("Updated: ")
        end
      end
    end

    it "prints a deprecation warning" do
      VCR.use_cassette("restore_contact_properties_and_groups") do
        file = build_file_with_matching_properties("contact")

        output = capture_stderr do
          invoke_rake_task(
            "hubspot:restore_properties",
            ["contact", file, hapikey]
          )
        end

        expect(output).to include("hubspot:restore_properties is deprecated")
      end
    end

    context "when a file is not provided" do
      it "raises an error" do
        missing_file = ""
        expected_error_msg = ":file is a required parameter"

        expect do
          invoke_rake_task(
            "hubspot:restore_properties",
            ["contact", missing_file, hapikey]
          )
        end.to raise_error(ArgumentError, expected_error_msg)
      end
    end

    context "given an unknown class" do
      it "raises an error" do
        file = Tempfile.new ""
        expected_error_msg = ':kind must be either "contact" or "deal"'

        expect do
          invoke_rake_task(
            "hubspot:restore_properties",
            ["unknown_class", file, hapikey]
          )
        end.to raise_error(ArgumentError, expected_error_msg)
      end
    end
  end

  def build_file_with_matching_properties(klass)
    file = Tempfile.new ""
    invoke_rake_task("hubspot:dump_properties", ["contact", file, hapikey])
    file
  end
end
