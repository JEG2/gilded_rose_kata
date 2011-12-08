module Aging
  def age
    update_quality
    update_sell_in
  end

  def update_sell_in
    self.sell_in -= 1
  end
  
  def update_quality
    reduce_quality(sell_in <= 0 ? 2 : 1)
  end
  
  def reduce_quality(amount)
    self.quality = [quality - amount, 0].max
  end
  
  def increase_quality(amount)
    self.quality = [quality + amount, 50].min
  end
end

module BetterWithAge
  def update_quality
    increase_quality(sell_in <= 0 ? 2 : 1)
  end
end

module Popular
  def update_quality
    increase_quality(
      case sell_in
      when -Float::INFINITY..0 then -quality
      when 1..5                then 3
      when 6..10               then 2
      else                          1
      end
    )
  end
end

module Legendary
  def update_sell_in
    # do nothing:  never has to be sold
  end

  def update_quality
    # do nothing:  does not degrade
  end
end

module Conjured
  def update_quality
    2.times do
      super
    end
  end
end

def prepare_for_aging(item)
  unless item.respond_to? :age
    item.extend(Aging)
    type = case item.name
           when /Aged Brie/i      then BetterWithAge
           when /Backstage pass/i then Popular
           when /Sulfuras/i       then Legendary
           when /Conjured/i       then Conjured
           end
    item.extend(type) if type
  end
  item
end

def update_quality(items)
  items.each do |item|
    prepare_for_aging(item).age
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

