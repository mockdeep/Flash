# Text registry: slug => description used in LLM prompts (era/register context
# matters for glossing judgment). Scripts take the slug as ARGV[0].
# Generated intermediates stay out of the repo, under tmp/.
OUTPUT_ROOT = File.expand_path("../../tmp/compendium_prototype/output", __dir__)
TEXTS = {
  "kongyiji" => "Lu Xun's short story 孔乙己 (1919, modern vernacular)",
  "xiyouji1" => "chapter 1 of 西游记 (Journey to the West, Ming dynasty c. 1592; vernacular novel prose mixed with classical verse)",
}.freeze
