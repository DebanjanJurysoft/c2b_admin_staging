<template>
    <div class="w-100 apartmentHolder" v-if="loading">
        <div class="text-center">
            <b-spinner variant="primary" label="Text Centered"></b-spinner>
        </div>
    </div>
    <div class="w-100 apartmentHolder" v-else>
        <div class="addApartment card" style="height: 750px;">
            <div class="p-3 text-center">
                <h3>{{ selected_user ? 'Update' : 'Add' }} User</h3>
                <div class="p-3">
                    <input type="text" v-model="full_name" class="" placeholder="Full Name">
                </div>
                <div class="p-3">
                    <b-form-select class="select-box my-2" v-model="selected_user_role" :options="user_role_list" value-field="id" text-field="role_name"></b-form-select>
                </div>
                <div class="p-3">
                    <input type="text" v-model="username" class="" placeholder="Email">
                </div>
                <div class="p-3" v-if="!selected_user && selected_user_role && user_role_list.find(e => e.id == selected_user_role).role_name != 'CUSTOMER'">
                    <input type="text" v-model="password" class="" placeholder="Password">
                </div>
                <div class="p-3" v-if="selected_user_role && user_role_list.find(e => e.id == selected_user_role).role_name == 'CUSTOMER'">
                    <input type="text" @input="() => {pancard = pancard.toUpperCase()}" v-model="pancard" class="" placeholder="PANCARD">
                </div>
                <div class="p-3">
                    <button class="btn2" v-if="selected_user" @click.prevent="resetForm"><i class="fa fa-ban"></i> Cancel</button>
                    <button class="btn2" @click.prevent="saveUser"><i class="fa fa-save"></i> Save</button>
                </div>
            </div>
        </div>
        <div v-if="user_list.length > 0 || customer_list.length > 0" style="width: 60%; display: flex; justify-content: space-between;">
            <div class="viewApartment card" style="height: 750px; padding: 30px; width: 47%; overflow-y: scroll; text-align: center;" v-if="user_list.length > 0">
                <h3>USERS</h3>
                <div class="card my-2" style="width: 100%;" v-for="(user, index) in user_list" :key="index">
                    <div class="card-body">
                        <h5 class="card-title">{{ user.fullname }}</h5>
                        <p class="card-text">User ID: {{ user.id }}</p>
                        <p class="card-text">Role: {{ user.user_role.role_name }}</p>
                        <button class="btn2" @click.prevent="editUser(user)"><i class="fa fa-pencil"></i> EDIT</button>
                        <button class="btn2" @click.prevent="deleteUser(user)"><i class="fa fa-trash"></i> DELETE</button>
                    </div>
                </div>
            </div>
            <div class="viewApartment card" style="height: 750px; padding: 30px; width: 47%; overflow-y: scroll; text-align: center;" v-if="customer_list.length > 0">
                <h3>CUSTOMERS</h3>
                <div class="card my-2" style="width: 100%;" v-for="(user, index) in customer_list" :key="index">
                    <div class="card-body">
                        <h5 class="card-title">{{ user.fullname }}</h5>
                        <p class="card-text">User ID: {{ user.id }}</p>
                        <p class="card-text">Role: CUSTOMER</p>
                        <button class="btn2" @click.prevent="editUser(user)"><i class="fa fa-pencil"></i> EDIT</button>
                        <!-- <button class="btn2" @click.prevent="deleteUser(user)"><i class="fa fa-trash"></i> DELETE</button> -->
                    </div>
                </div>
            </div>
        </div>
        <div class="viewApartment" v-else>
            <div class="card my-2">
                <div class="card-body">
                    <h5 class="card-title">No users found.</h5>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Swal from 'sweetalert2'
export default {
    data() {
        return {
            loading: true,
            user_list: [],
            user_role_list: [],
            selected_user_role: null,
            selected_user: null,
            full_name: null,
            username: null,
            password: null,
            pancard: null,
            customer_list: null,
        }
    },
    async mounted() {
        this.loading = true
        await this.fetchUserRoleList()
        await this.fetchUserList()
        this.loading = false
    },
    methods: {
        deleteUser(user) { 
            Swal.fire({
                title: 'Are you sure?',
                text: "You won't be able to revert this!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, delete it!'
            }).then(async (result) => {
                if (result.isConfirmed) {
                    const response = await this.$axios.post('/delete-user', {
                        id: user.id
                    })
                    // console.log(response);
                    Swal.fire({
                        position: 'top-end',
                        icon: response.data.message.includes('success') ? 'success' : 'error',
                        title: response.data.message,
                        showConfirmButton: false,
                        timer: 1500
                    })
                    this.fetchUserList()
                }
            })
        },
        editUser(user) { 
            this.selected_user = user
            this.full_name = user.fullname
            this.selected_user_role = user.role_id ? user.role_id : this.user_role_list.find(e => e.role_name == 'CUSTOMER').id
            this.username = user.email
            if (!user.role_id) {
                this.pancard = user.pancard
            }
        },
        async fetchUserRoleList() {
            const response = await this.$axios.get('/get-user-roles')
            this.user_role_list = response.data.data
            this.user_role_list.unshift({
                id: null,
                role_name: 'Select an user role.'
            })
        },
        async fetchUserList() {
            const response = await this.$axios.get('/get-user-list')
            this.user_list = response.data.data.users
            this.customer_list = response.data.data.customer
        },
        resetForm() { 
            this.selected_user = null
            this.full_name = null
            this.selected_user_role = null
            this.username = null
            this.password = null
        },
        async saveUser() {
            if (!this.full_name || this.full_name.trim() == '') {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter full name.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return 
            }
            if (!this.selected_user_role) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Select an user role.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return 
            }
            if (!this.username || this.username.trim() == '') {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter username.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return 
            }
            if (this.user_role_list.find(e => e.id == this.selected_user_role).role_name != 'CUSTOMER' && !this.selected_user && (!this.password || this.password.trim() == '')) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter password.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return 
            }
            if (this.user_role_list.find(e => e.id == this.selected_user_role).role_name == 'CUSTOMER' && (!this.pancard || this.pancard.trim() == '')) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter pancard no.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return 
            }
            if (this.user_role_list.find(e => e.id == this.selected_user_role).role_name == 'CUSTOMER') {
                const customer_data = !this.selected_user ? {
                    fullname: this.full_name,
                    email: this.username,
                    pancard: this.pancard,
                } : {
                    id: this.selected_user.id,
                    fullname: this.full_name,
                    email: this.username,
                    pancard: this.pancard,
                }
                const response = await this.$axios.post(this.selected_user ? '/update-customer' : '/add-customer', customer_data)
                Swal.fire({
                    position: 'top-end',
                    icon: response.data.message.includes('success') ? "success" : "error",
                    title: response.data.message,
                    showConfirmButton: false,
                    timer: 1500
                })
                this.fetchUserList()
                this.resetForm()
                return
            }
            const user_data = !this.selected_user ? {
                full_name: this.full_name,
                role_id: this.selected_user_role,
                email: this.username,
                password: this.password,
            } : {
                id: this.selected_user.id,
                full_name: this.full_name,
                role_id: this.selected_user_role,
                email: this.username,
            }
            const response = await this.$axios.post(this.selected_user ? '/update-user' : '/add-user', user_data)
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? "success" : "error",
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
            this.fetchUserList()
            this.resetForm()
        }
    }
}
</script>

<style>
@import url("https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css");
.apartmentHolder {
    width: 100%;
    height: max-content;
    display: flex;
}
.addApartment {
    width: 40%;
    float: left;
}

.viewApartment {
    float: left;
}
</style>