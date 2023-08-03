<template>
  <div class="row text-center" style="padding-top: 30px; padding-left: 30px; margin: 0px;">
    <div class="d-inline-flex flex-column border navbar" :class="showMenuNames ? 'col-2' : 'col-1'"
      style="background: #f3f7ff;  height: 100vh; margin: 0px; margin-top: -30px ; margin-left: -30px ;transition: 0.5s; justify-content: space-between;">
      <div>
        <div class="text-center mb-5">
          <a style="font-size: 25px;" v-if="!showMenuNames" href="/">TS</a>
          <a style="font-size: 25px;" v-if="showMenuNames" href="/">TRENDSQUARE</a>
          <span
            style="font-size: 20px; position: absolute; margin-left: 13px; background: white; width: 32px; border-radius: 30px; cursor: pointer; z-index: 1;"
            :style="!showMenuNames ? 'margin-left: 26px' : 'margin-left: 14px;'" @click.prevent="changeShowMenu">
            <i v-if="!showMenuNames" class="fa fa-angle-right"></i>
            <i v-if="showMenuNames" class="fa fa-times"></i>
          </span>
        </div>
        <span v-for="(menu_item, index) in menu" :key="index" class="align-items-left" style="
            width: 100%;
            display: flex;
            margin-bottom: 15px;
            flex-direction: column;
            gap: 10px;
            cursor: pointer;  
            text-align: left;
          " :class="selectedMenu.name == menu_item.name ? 'btn2' : 'btn3'" 
          @click.prevent="enableDropDown(menu_item)">
          <h6 class="pt-1">
            <i :class="menu_item.icon" class="mr-1"></i><a v-if="showMenuNames">{{ menu_item.name }}</a>
          </h6>
        </span>
      </div>
      <span class="btn2" @click.prevent="login()"
        style="width: 100%; cursor: pointer; text-transform: uppercase; text-align: center; align-items: center;">
        <!-- <img class="user" width="100%" src="~/static/user-new.png" alt=""> -->
        <span class="navItems" v-if="showMenuNames">Logout <i class="ml-1 fa fa-sign-out"></i></span>
        <span v-else><i class="fa fa-sign-out"></i></span>
      </span>
      <!-- <div style="overflow-x: scroll; overflow: hidden;" class="d-flex flex-column align-items-center">
      </div> -->
    </div>
    <div :class="showMenuNames ? 'col-10' : 'col-11'">
      <div class="row" style="margin: 0px; width: 100%;">
        <!-- project  -->
        <div class="col-12" v-if="selectedMenu.name == 'PROJECT'">
          <Project @changeTabOnChange="changeTab" />
        </div>
        <!-- project end  -->
        <!-- apartment  -->
        <div class="col-12" v-if="selectedMenu.name == 'BLOCKS'">
          <Apartments @changeTabOnChange="changeTab"/>
        </div>
        <!-- apartment end  -->
        <!-- units  -->
        <div class="col-12" v-if="selectedMenu.name == 'UNITS'">
          <Units />
        </div>
        <!-- units end  -->
        <!-- users  -->
        <div class="col-12" v-if="selectedMenu.name == 'USERS'">
          <User />
        </div>
        <!-- users end  -->
        <!-- user details  -->
        <div class="col-12" v-if="selectedMenu.name == 'UNIT DETAILS'">
          <Unit_details />
        </div>
        <!-- user details end  -->
        <!-- payments details  -->
        <div class="col-12" v-if="selectedMenu.name == 'PAYMENTS'">
          <Payment />
        </div>
        <!-- payments details end  -->
        <!-- dashboard details  -->
        <div class="col-12" v-if="selectedMenu.name == 'DASHBOARD'">
          <Dashboard />
        </div>
        <!-- dashboard details end  -->
      </div>
    </div>
  </div>
</template>

<script>
import Units from '../components/units.vue';
import Apartments from '../components/apartments.vue';
import User from '../components/users.vue';
import Unit_details from "../components/unit_details.vue";
import Payment from "../components/payments.vue";
import Project from '../components/project.vue';
import Dashboard from '../components/dashboard.vue';
export default {
  name: "IndexPage",
  data() {
    return {
      showMenuNames: true,
      showDropDown: false,
      name: "",
      selectedMenu: {
        name: "PROJECT",
        page_link: "/project",
        role_id_list: [1, 2],
      },
      menu: [
        
      ],
      otherMenu: [
      {
          name: "DASHBOARD",
          icon: 'fa fa-tachometer',
          page_link: "/dashboard",
          role_id_list: [1, 2],
        },
        {
          name: "UNIT DETAILS",
          icon: 'fa fa-info',
          page_link: "/units",
          role_id_list: [1, 2, 3],
        },
      ],
      dropdownMenu: [
        {
          name: "PROJECT",
          icon: 'fa fa-file-o',
          page_link: "/project",
          role_id_list: [1, 2],
        },
        {
          name: "BLOCKS",
          icon: 'fa fa-cube',
          page_link: "/blocks",
          role_id_list: [1, 2],
        },
        {
          name: "UNITS",
          icon: 'fa fa-cubes',
          page_link: "/units",
          role_id_list: [1, 2],
        },
        {
          name: "USERS",
          icon: 'fa fa-user',
          page_link: "/users",
          role_id_list: [1, 2, 3],
        },
        {
          name: "PAYMENTS",
          icon: 'fa fa-money',
          page_link: "/payments",
          role_id_list: [1, 2, 3],
        },
      ]
    };
  },
  mounted() {
    if (this.$auth.loggedIn) {
      this.menu = this.otherMenu
      this.enableDropDown(this.menu[0])
      const user = this.$auth.user
      this.menu = this.menu.filter(e => e.role_id_list.includes(user.role.id))
      this.selectedMenu = this.menu[0]
      this.name = user.fullname.split(' ').length == 2 ? ` ${user.fullname.split(' ')[0][0]}${user.fullname.split(' ')[1][0]}` : user.fullname.split(' ')[0][0]
    } else {
      this.$router.push('/login')
    }
  },
  methods: {
    enableDropDown(menu) {
      const user = this.$auth.user
      if (menu.name == 'UNIT DETAILS' && this.selectedMenu.name == 'UNIT DETAILS') {
        if (this.menu.find(e => e.name == 'USERS')) {
          this.menu = this.otherMenu.filter(e => e.role_id_list.includes(user.role.id))
        } else {
          this.menu = this.otherMenu.filter(e => e.role_id_list.includes(user.role.id)).concat(this.dropdownMenu.filter(e => e.role_id_list.includes(user.role.id)))
        }
        this.goToPage(menu)
      } else {
        this.goToPage(menu)
      }
    },
    changeShowMenu() {
      this.showMenuNames = !this.showMenuNames
    },
    changeTab(tab) {
      this.selectedMenu = this.menu.find(e => e.name == tab)
    },
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
      localStorage.removeItem('project')
      this.selectedMenu = menu;
    },
  },
  components: { Apartments, Units, User, Unit_details, Payment, Payment, Project, Dashboard }
};
</script>



<style>
@import url("https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css");
.user {
  height: 40px !important;
  width: 40px !important;
  border-radius: 50%;
  overflow: hidden;
}

/* .navItems {
  border-radius: 20px;
  width: 100%;
  padding: 5px;
  padding-left: 20px;
  padding-top: 10px;
  padding-right: 20px;
  box-shadow: 1px 3px #E0E9FF;
  border: 1px solid #E0E0E0;
  background: rgba(255, 255, 255, 0.10);
  backdrop-filter: blur(12px);
} */
/* .navItems:hover {
  box-shadow: none;
}
.navItems > h5 {
  color: #000;
  font-family: Poppins;
  font-size: 14px;
  font-style: normal;
  line-height: normal;
} */
</style>