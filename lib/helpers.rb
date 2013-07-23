helpers do

  def validate(params, required_params=[], cleared_params=[])
    required_params.each do |rp|
      return [false, "#{rp} not provided"] unless params.include?(rp)
    end
    clean_params = {}
    (required_params & params.keys).each do |p|    
      return [false, "String format required for #{p}"] unless params[p].kind_of? String
      clean_params[p] = cleared_params.include?(p)?params[p]:Sanitize.clean(params[p])
    end    
    return [true, "Clean", clean_params]
  end  
  
end