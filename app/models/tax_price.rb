class TaxPrice < ActiveRecord::Base
  # def get_price_by_amount(amount)
  #   # tax_price = self.find_by(tax_code: tax_code)
  #   # return 0.to_d if tax_price.blank?

  #   weight  = get_weight_by_amount(amount.to_i)

  #   return TaxPrice.get_price_by_weight(weight)
  # end

  def get_weight_by_amount(amount)
    if amount <= 0
      return 0
    end
    
    if amount < box_amount
      return amount / piece_amount * piece_weight
    else
      return amount / box_amount * box_weight + amount % box_amount / piece_amount * piece_weight
    end
  end

  def self.get_price_by_weight(weight)
    weight = weight.to_i
    if weight <= 1000
      return 10
    elsif weight > 21000 && weight <= 100000
      return 200
    else
      if weight > 100000
        base_price = 200
        base_weight = 100000
      else
        base_price = 10
        base_weight = 1000
      end
      
      if weight % 1000 == 0
        return (base_price + ((weight - base_weight) / 1000)*2)
      else
        return (base_price + ((weight - base_weight) / 1000)*2 + 2)
      end
    end
  end
end