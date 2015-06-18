module.exports = new class ProfileHelper

  visitProfilePage: ->
    element(By.css('.navbar-user-options button')).click()
    element(By.css('.navbar-user-options__profile-link')).click()

  load: ->
    browser.get('http://localhost:8000/development/setup_user_profile')

  updateProfile: (name, username, email) ->
    @changeName(name)
    @changeUsername(username)
    @changeEmail(email)
    @submitForm()

  nameInput: ->
    element(By.css('.profile-page__name-input'))

  usernameInput: ->
    element(By.css('.profile-page__username-input'))

  emailInput: ->
    element(By.css('.profile-page__email-input'))

  changeName: (text) ->
    @nameInput().clear().sendKeys(text or 'My New name')

  changeUsername: (text) ->
    @usernameInput().clear().sendKeys(text or 'mynewusername')

  changeEmail: (text) ->
    @emailInput().clear().sendKeys(text or 'mynew@email.com')

  submitForm: ->
<<<<<<< HEAD
    element(By.css('.profile-page__update-button')).click()
=======
    element(By.css('')).click()
>>>>>>> add support to test emails
