import { mount } from '@vue/test-utils'
import StatusTracker from './StatusTracker.vue'
import { describe, expect, it } from 'vitest'
import router from '../../router'
import PrimeVue from 'primevue/config'

describe('StatusTracker', () => {
  it('should render the component', async () => {
    const orderId = 123
    const wrapper = mount(StatusTracker, {
      props: {
        orderId
      },
      global: {
        plugins: [router, PrimeVue]
      }
    })

    expect(wrapper).toBeTruthy()
  })
})
