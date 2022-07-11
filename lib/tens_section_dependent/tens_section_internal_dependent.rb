require_relative '../tens_section_dependent.rb'

class TensSectionInternalDependent < TensSectionDependent
  # Data is included as internal tokens
  def internal_tokens
    super + data
  end
end

