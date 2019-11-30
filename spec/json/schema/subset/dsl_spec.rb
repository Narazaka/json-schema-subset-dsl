RSpec.describe Json::Schema::Subset::DSL do
  subject { described_class.new(&block).compile! }

  context "full" do
    let(:block) do
      lambda do |domain|
        title! "Foo"
        id :integer, minimum: 1
        name :string, minLength: 1
        flag :boolean, optional: true
        obj :object do
          id :integer
          foos :array, optional: true do
            string! title: "Str1"
          end
          bars :array do
            title! "Str2"
            string! minLength: 1
            null!
          end
          bazs :array do
            id :integer
          end
          hoge :object do
            cref! :aa
          end
          fuga :object do
            ref! :aa
          end
        end
      end
    end

    let(:schema) do
      {
        "type" => "object",
        "properties" => {
          "id" => { "minimum" => 1, "type" => "integer" },
          "name" => { "minLength" => 1, "type" => "string" },
          "flag" => { "type" => "boolean" },
          "obj" => {
            "type" => "object",
            "properties" => {
              "id" => { "type" => "integer" },
              "foos" => { "items" => { "title" => "Str1", "type" => "string" }, "type" => "array" },
              "bars" => {
                "items" => { "minLength" => 1, "type" => %w[string null], "title" => "Str2" }, "type" => "array"
              },
              "bazs" => {
                "items" => {
                  "type" => "object", "properties" => { "id" => { "type" => "integer" } }, "required" => %w[id]
                },
                "type" => "array",
              },
              "hoge" => { "$ref" => "#/components/aa" },
              "fuga" => { "$ref" => "aa" },
            },
            "required" => %w[id bars bazs hoge fuga],
          },
        },
        "required" => %w[id name obj],
        "title" => "Foo",
      }
    end

    it_is_asserted_by { subject == schema }
  end

  context "simple" do
    let(:block) do
      lambda do |domain|
        title! "Example"
        id :integer
        name :string, minLength: 1, optional: true
        items :array, optional: true do
        end
        other_names :array, optional: true do
          string!
          null!
        end
        meta :object do
          description :string
          params :array do
            ref! "#/components/Param"
          end
          opt_params :array do
            cref! "OptParam"
          end
          uuid :ref, "#/UUID", optional: true
        end
      end
    end

    let(:schema) do
      {
        "type" => "object",
        "properties" => {
          "id" => { "type" => "integer" },
          "name" => { "minLength" => 1, "type" => "string" },
          "items" => { "items" => { "type" => "object", "properties" => {} }, "type" => "array" },
          "other_names" => { "items" => { "type" => %w[string null] }, "type" => "array" },
          "meta" => {
            "type" => "object",
            "properties" => {
              "description" => { "type" => "string" },
              "params" => { "items" => { "$ref" => "#/components/Param" }, "type" => "array" },
              "opt_params" => { "items" => { "$ref" => "#/components/OptParam" }, "type" => "array" },
              "uuid" => { "$ref" => "#/UUID" },
            },
            "required" => %w[description params opt_params],
          },
        },
        "required" => %w[id meta],
        "title" => "Example",
      }
    end

    it_is_asserted_by { subject == schema }
  end
end
