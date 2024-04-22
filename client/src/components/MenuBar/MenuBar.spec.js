import { mount, RouterLinkStub} from '@vue/test-utils'
import MenuBar from './MenuBar.vue'
import router from '../../router'
import PrimeVue from 'primevue/config'
import { describe, expect, it, vi } from 'vitest'
import useAuthentication from '../../hooks/useAuthentication'


describe('MenuBar', () => {
  it('renders correctly with authenticated user', async () => {
    const { setCredentials } = useAuthentication()
    setCredentials({
        "access_token": "eyJhbGciOiAiSFMyNTYiLCAidHlwIjogIkpXVCJ9.eyJzdWIiOiAidGVzdEBnbWFpbC5jb20iLCAiZXhwIjogMTcxMjY2MDAxOC42MDUwNjd9.SmMPeZBZMAfNGVty61vzdPOk/jwxn3ClJSJK0WXgtqA=",
        "type": "Bearer",
        "expires_in": 7200
    })

    const wrapper = mount(MenuBar, {
      global: {
        plugins: [router, PrimeVue]
      }
    })

    // Check if "Log out" button is rendered
    expect(wrapper.find('.authentication-button').text()).toBe('Log out')
  })

  it('renders correctly with unauthenticated user', async () => {
    const { removeCredentials } = useAuthentication()
    removeCredentials()

    const wrapper = mount(MenuBar, {
      global: {
        plugins: [router, PrimeVue]
      }
    })


    // Check if "Sign up" button is rendered
    expect(wrapper.find('.sign-up-button').text()).toBe('Sign up')

    // Check if "Sign in" button is rendered
    expect(wrapper.find('.sign-in-button').text()).toBe('Sign in')
  })

  it('calls appropriate methods on button clicks', async () => {
    const routerPushSpy = vi.spyOn(router, 'push')
    const wrapper = mount(MenuBar, {
        global: {
            plugins: [router, PrimeVue]
        }
    })
    

    // Simulate click on "Sign in" button
    await wrapper.find('.sign-in-button').trigger('click')
    expect(routerPushSpy).toHaveBeenLastCalledWith({name: 'Signin'})

    // Simulate click on "Sign up" button
    await wrapper.find('.sign-up-button').trigger('click')
    expect(routerPushSpy).toHaveBeenLastCalledWith({name: 'Signup'})
  })
})
