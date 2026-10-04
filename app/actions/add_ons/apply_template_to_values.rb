class AddOns::ApplyTemplateToValues
  extend LightService::Action
  expects :add_on

  executed do |context|
    add_on = context.add_on
    add_on.values.extend(DotSettable)

    variables = add_on.metadata['template'] || {}
    variables.keys.each do |key|
      variable = variables[key]

      if variable.is_a?(Hash) && variable['type'] == 'size'
        add_on.values.dotset(key, "#{variable['value']}#{variable['unit']}")
      else
        variable_definition = add_on.chart_definition['template'].find { |t| t['key'] == key }
        next if variable_definition['generate'] && variable.blank?

        if variable_definition['type'] == 'integer'
          add_on.values.dotset(key, variable.to_i)
        else
          add_on.values.dotset(key, variable)
        end
      end
    end

    (add_on.chart_definition['template'] || []).select { |t| t['generate'] }.each do |definition|
      next if add_on.values.dig(*definition['key'].split('.')).present?

      add_on.values.dotset(definition['key'], SecureRandom.alphanumeric(24))
    end
  end
end
