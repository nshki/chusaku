# frozen_string_literal: true

class TacosController < ApplicationController
  def show; end

  # This is an example of generated annotations that come with Rails 6
  # scaffolds. These should be replaced by Chusaku annotations.
  # POST /api/tacos
  # PATCH/PUT /api/tacos/1
  def create; end

  # Update all the tacos!
  # @route this should be deleted, it's not a valid route.
  # We should not see a duplicate @route in this comment block.
  # @route PUT /api/tacos/:id (taco)
  # But this should remain (@route), because it's just words.
  def update; end

  # This route doesn't exist, so it should be deleted.
  # @route DELETE /api/tacos/:id
  def destroy
    puts('Tacos are indestructible')
  end

  private

    def tacos_params
      params.require(:tacos).permit(:carnitas)
    end
end
