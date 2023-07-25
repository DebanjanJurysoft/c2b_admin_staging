<template>
  <div>
    <div class="w-100 p-3 d-inline-flex bg-light border">
      <div class="w-25">
        <h3><a href="/">TRENDSQUARE</a></h3>
      </div>
      <div class="w-75 d-flex flex-row-reverse align-items-center">
        <h3 style="cursor: pointer;">
          <a @click.prevent="login()" style="text-transform: uppercase;" class="mx-2"><i class="fa fa-user"></i>{{ name }}</a>
        </h3>
        <div
          v-for="(menu_item, index) in menu"
          :key="index"
          class="mx-3"
          style="cursor: pointer"
        >
          <h5 :class="selectedMenu.name == menu_item.name ? 'text-primary' : ''">
            <a @click.prevent="goToPage(menu_item)">{{ menu_item.name }}</a>
          </h5>
        </div>
      </div>
    </div>
    <div class="w-100 py-1">
      <div class="row h-100" style="margin: 0px;">
        <!-- apartment  -->
        <div class="col-12 card" v-if="selectedMenu.name == 'APARTMENT'">
          <Apartments />
        </div>
        <!-- apartment end  -->
        <!-- units  -->
        <div class="col-12 card" v-if="selectedMenu.name == 'UNITS'">
          <Units />
        </div>
        <!-- units end  -->
        <!-- users  -->
        <div class="col-12 card" v-if="selectedMenu.name == 'USERS'">
          <User />
        </div>
        <!-- users end  -->
        <!-- user details  -->
        <div class="col-12 card" v-if="selectedMenu.name == 'UNIT_DETAILS'">
          <Unit_details />
        </div>
        <!-- user details end  -->
      </div>
    </div>
  </div>
</template>

<script>
import Units from '../components/units.vue';
import Apartments from '../components/apartments.vue';
import User from '../components/users.vue';
import Unit_details from "../components/unit_details.vue";
export default {
    name: "IndexPage",
    data() {
        return {
            name: "",
            selectedMenu: {
              name: "APARTMENT",
              page_link: "/apartment",
              role_id_list: [1, 2],
            },
            menu: [
                {
                    name: "APARTMENT",
                    page_link: "/apartment",
                    role_id_list: [1, 2],
                },
                {
                  name: "UNITS",
                  page_link: "/units",
                  role_id_list: [1, 2, 3],
                },
                {
                  name: "UNIT_DETAILS",
                  page_link: "/units",
                  role_id_list: [1, 2, 3],
                },
                {
                    name: "USERS",
                    page_link: "/users",
                    role_id_list: [1, 2],
                },
            ],
        };
    },
  mounted() {
    if (this.$auth.loggedIn) {
      const user = this.$auth.user
      this.menu = this.menu.filter(e => e.role_id_list.includes(user.role.id))
      this.selectedMenu = this.menu[0]
      this.name = user.fullname.split(' ').length == 2 ? ` ${user.fullname.split(' ')[0][0]}${user.fullname.split(' ')[1][0]}` : user.fullname.split(' ')[0][0]
    } else {
      this.$router.push('/login')
    }
  },
  methods: {
    login() { 
      if (this.$auth.loggedIn) {
        this.$auth.logout()
        setTimeout(() => {
          window.location.reload(true)
        }, 10);
      } else {
        this.$router.push('/login')
      }
    },
    goToPage(menu) {
      this.selectedMenu = menu;
    },
  },
  components: { Apartments, Units, User, Unit_details }
};
</script>
