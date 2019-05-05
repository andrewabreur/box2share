class CreatesPlan

  attr_accessor :remote_id, :name,
      :price_cents, :interval,
      :space_allowed, :plan

  def initialize(remote_id:, name:,
    price_cents:, interval:, space_allowed:)
    @remote_id = remote_id
    @name = name
    @price_cents = price_cents
    @interval = interval
    @space_allowed = space_allowed
  end

  def run
    remote_plan = Stripe::Plan.create(
        id: remote_id, amount: price_cents,
        currency: "eur", interval: interval,
        product: "box2share", nickname: name)
    self.plan = Plan.create(
        remote_id: remote_plan.id, name: name,
        price_cents: price_cents, interval: interval,
        space_allowed: space_allowed,
        status: :active)
  end

end
