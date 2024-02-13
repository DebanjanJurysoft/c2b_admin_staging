<template>
    <div class="row p-3">
        <div class="col-6 col-md-6 col-sm-12 col-lg-6 d-flex flex-column gap10">
            <div class="d-flex flex-row card align-items-center justify-content-between p-3" v-for="(admin, admin_index) in admins" :key="admin_index" @click.prevent="selectAnAdmin(admin)">
                <i class="fa fa-user" ></i>
                {{ admin.fullname }}({{ admin.email }})
            </div>
        </div>
        <div class="col-6 col-md-6 col-sm-12 col-lg-6 d-flex flex-column gap10" v-if="loadPermission">
            <div v-for="(permissions, permission_index) in permissions" :key="permission_index">
                <b-form-checkbox v-model="permissions.has_permission" @change="updatePermission" name="check-button" switch>
                    {{permissions.module_name.toUpperCase()}}
                </b-form-checkbox>
            </div>
        </div>
    </div>
</template>


<script>
export default {
    data() {
        return {
            loader: true,
            admins: [],
            loadPermission: false,
            selected_admin: null,
            permissions: [
                {
                    module_name: 'home',
                    has_permission: false
                },
                {
                    module_name: 'vendors',
                    has_permission: false
                },
                {
                    module_name: 'stores',
                    has_permission: false
                },
                {
                    module_name: 'malls',
                    has_permission: false
                },
                {
                    module_name: 'inventory',
                    has_permission: false
                },
                {
                    module_name: 'products',
                    has_permission: false
                },
                {
                    module_name: 'banners',
                    has_permission: false
                },
                {
                    module_name: 'addons',
                    has_permission: false
                },
                {
                    module_name: 'sub-category',
                    has_permission: false
                },
                {
                    module_name: 'attributes',
                    has_permission: false
                },
                {
                    module_name: 'coupons',
                    has_permission: false
                },
                {
                    module_name: 'orders',
                    has_permission: false
                },
                {
                    module_name: 'payments',
                    has_permission: false
                },
                {
                    module_name: 'plans',
                    has_permission: false
                },
                {
                    module_name: 'notifications',
                    has_permission: false
                },
                {
                    module_name: 'reports',
                    has_permission: false
                },
                {
                    module_name: 'customers',
                    has_permission: false
                },
                {
                    module_name: 'account',
                    has_permission: false
                },
                {
                    module_name: 'privacy policy',
                    has_permission: false
                },
                {
                    module_name: 'feedback',
                    has_permission: false
                },
            ],
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchAdmins()
        this.loader = false
    },
    methods: {
        async updatePermission() {
            const response = await this.$axios({
                method: 'POST',
                url: '/update-permissions',
                data: {
                    admin_id: this.selected_admin.id,
                    permissions: this.permissions
                }
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
        },
        selectAnAdmin(admin) {
            if (this.loadPermission && this.selected_admin == admin) {
                this.selected_admin = null
                this.permissions = this.permissions.map(e => {
                    return {
                        ...e,
                        has_permission: false
                    }
                })
                this.loadPermission = false
                return
            }
            this.selected_admin = admin
            this.permissions = this.permissions.map(e => {
                const avl_data = admin.permissions.find(es => es.module_name == e.module_name)
                return {
                    ...e,
                    has_permission: avl_data ? avl_data.has_permission : false
                }
            })
            this.loadPermission = true
        },
        async fetchAdmins() {
            const response = await this.$axios.get('/fetch-admin')
            this.admins = response.data.admins
        }
    }
}
</script>