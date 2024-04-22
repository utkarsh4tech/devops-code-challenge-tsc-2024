import { mount } from '@vue/test-utils'
import CartButton from './CartButton.vue'
import useShoppingCart from '@/hooks/useShoppingCart'
import { describe, expect, it } from 'vitest'
import router from '../../router'
import PrimeVue from 'primevue/config'

describe('CartButton', () => {
  it('renders Add to cart button when plate is not in cart', async () => {
    const { clearCurrentCart } = useShoppingCart()
    clearCurrentCart()

    const wrapper = mount(CartButton, {
      props: {
        plateId: 1,
        withLabel: true
      },
      global: {
        plugins: [router, PrimeVue]
      }
    })

    // Check if "Add to cart" button is rendered
    expect(wrapper.find('.not-in-cart').exists()).toBe(true)
    expect(wrapper.find('.not-in-cart').text()).toBe('Add to cart')
  })

  it('renders Delete button when plate is in cart', async () => {
    const { addPlate } = useShoppingCart()
    addPlate(1, 1)

    const wrapper = mount(CartButton, {
      props: {
        plateId: 1,
        withLabel: true
      },
      global: {
        plugins: [router, PrimeVue]
      }
    })

    // Check if "Delete" button is rendered
    expect(wrapper.find('.in-cart').exists()).toBe(true)
    expect(wrapper.find('.in-cart').text()).toBe('Delete')
  })
})
