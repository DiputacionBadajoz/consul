require 'rails_helper'

feature 'Admin settings' do

  background do
    @setting1 = create(:setting)
    @setting2 = create(:setting)
    @setting3 = create(:setting)
    login_as(create(:administrator).user)
  end

  scenario 'Index' do
    visit admin_settings_path

    expect(page).to have_content @setting1.key
    expect(page).to have_content @setting2.key
    expect(page).to have_content @setting3.key
  end

  scenario 'Update' do
    visit admin_settings_path

    within("#edit_setting_#{@setting2.id}") do
      fill_in "setting_#{@setting2.id}", with: 'Super Users of level 2'
      click_button 'Update'
    end

    expect(page).to have_content 'Value updated'
  end

  describe "Update map" do

    scenario "Should not be able when map feature deactivated" do
      Setting['feature.map'] = false
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path

      expect(page).not_to have_content "Map configuration"
    end

    scenario "Should be able when map feature activated" do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path

      expect(page).to have_content "Map configuration"
    end

    scenario "Should show successful notice" do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)
      visit admin_settings_path

      within "#map-form" do
        click_on "Update"
      end

      expect(page).to have_content "Map configuration updated succesfully"
    end

    scenario "Should display marker by default", :js do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path

      expect(find("#latitude", visible: false).value).to eq "51.48"
      expect(find("#longitude", visible: false).value).to eq "0.0"
    end

    scenario "Should update marker", :js do
      Setting['feature.map'] = true
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#admin-map").click
      within "#map-form" do
        click_on "Update"
      end

      expect(find("#latitude", visible: false).value).not_to eq "51.48"
      expect(page).to have_content "Map configuration updated succesfully"
    end

  end

  describe "Skip verification" do

    scenario "deactivate verification", :js do
      Setting["feature.user.skip_verification"] = 'true'
      setting = Setting.where(key: "feature.user.skip_verification").first
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#edit_setting_#{setting.id} .button").click

      page.accept_confirm do
        click_button('OK')
      end

      user = create(:user, sign_in_count: 1)
      login_through_form_as(user)

      expect(page).to have_current_path(welcome_path)
    end

    scenario "activate verification", :js do
      Setting["feature.user.skip_verification"] = 'false'
      setting = Setting.where(key: "feature.user.skip_verification").first
      admin = create(:administrator).user
      login_as(admin)

      visit admin_settings_path
      find("#edit_setting_#{setting.id} .button").click

      page.accept_confirm do
        click_button('OK')
      end

      user = create(:user, sign_in_count: 1)
      login_through_form_as(user)

      expect(page).to have_current_path(root_path)
    end

  end

end
