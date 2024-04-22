import { createRouter, createWebHashHistory } from 'vue-router'

import Menu from '@/views/menu'
import Orders from '@/views/orders'
import Signin from '@/views/signin'
import Signup from '@/views/signup'
import ShoppingCart from '@/views/shopping-cart'
import Plate from '@/views/plate'
import useAuthentication from '../hooks/useAuthentication'

// #region [UTILS]
/**
 * Safe guard to execute to check if user is authenticated.
 * Redirect to sign in page if not authenticated.
 */
const checkCredentials = (to, from, next) => {
  if (sessionStorage.getItem('access_token')) {
    next();
    return;
  }
  next({ name: 'Signin' });
 };
// #endregion [UTILS]

//  #region [ROUTES]

// Open routes do not require authentication and do not appear in the menu.
const openRoutes = [
  {
    name: 'Signin',
    path: '/signin',
    component: Signin
  },
  {
    name: 'Signup',
    path: '/signup',
    component: Signup
  },
  {
    name: 'Cart',
    path: '/cart',
    component: ShoppingCart,
    meta: {
      showMenuBar: true
    }
  },
  {
    name: 'Plate',
    path: '/plate/:id',
    component: Plate,
    meta: {
      showMenuBar: true
    }
  },
]

// Open menu routes do not require authentication and appear in the menu.
const openMenuRoutes = [
  {
    name: 'Menu',
    path: '/',
    component: Menu,
    meta: {
      showMenuBar: true
    },
  },
  
]

// Restricted routes require authentication and appear in the menu if authenticated.
const restrictedMenuRoutes = [
  {
    name: 'Orders',
    path: '/orders',
    component: Orders,
    beforeEnter: [checkCredentials],
    meta: {
      showMenuBar: true
    },
  }
]

const routes = [
  ...openMenuRoutes,
  ...openRoutes,
  ...restrictedMenuRoutes
]
//  #endregion [ROUTES]


const router = createRouter({
  history: createWebHashHistory(),
  routes,
})

export default router;

export { openMenuRoutes, restrictedMenuRoutes, openRoutes }