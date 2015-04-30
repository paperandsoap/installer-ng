supervisor_service 'crond' do
  action service_is_up?(node, 'crond') ? [:stop, :disable] : [:disable]
end
