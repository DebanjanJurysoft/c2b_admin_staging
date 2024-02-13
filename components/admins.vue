<template>
    <div v-if="loader" class="loader">
        <Loader />
    </div>
    <div v-else class="table-container">
        <div class="d-flex">
            <button class="button" @click.prevent="openAddEditModal">
                <i class="fa fa-plus mr-2"></i>
                Add New Admin
            </button>
        </div>
        <table class="main-table">
            <thead>
                <th class="heading">
                    SL No.
                </th>
                <th class="heading">
                    id
                </th>
                <th class="heading">
                    Full Name
                </th>
                <th class="heading">
                    Email
                </th>
                <th class="heading">
                    action
                </th>
            </thead>
            <tbody>
                <tr
                    class="table-rows"
                    v-for="(admin, row_index) in admins"
                    :key="row_index"
                >
                    <td>{{ row_index + 1 }}</td>
                    <td>{{ admin.id }}</td>
                    <td>{{ admin.fullname }}</td>
                    <td>{{ admin.email }}</td>
                    <td class="d-flex">
                        <button class="btn btn-outline-primary" @click.prevent="openAddEditModal(admin)">
                            <i class="fa fa-pencil"></i>
                        </button>
                    </td>
                </tr>
            </tbody>
        </table>
        <b-modal hide-footer id="addEditModal" :title="modal_title" @hide="closeModal">
            <template v-if="!edit_id">
                <div class="d-flex flex-column" style="gap: 10px;">
                    <div class="d-flex flex-column">
                        <label class="input-label">Full Name: </label>
                        <b-form-input v-model="modal_data_add.fullname" placeholder="Enter Full Name"></b-form-input>
                    </div>
                    <div class="d-flex flex-column">
                        <label class="input-label">Email: </label>
                        <b-form-input v-model="modal_data_add.email" placeholder="Enter Email"></b-form-input>
                    </div>
                    <div class="d-flex flex-column">
                        <label class="input-label">Password: </label>
                        <b-form-input v-model="modal_data_add.password" placeholder="Enter Password"></b-form-input>
                    </div>
                    <div class="d-flex flex-column">
                        <label class="input-label">Confirm Password: </label>
                        <b-form-input v-model="modal_data_add.cpassword" placeholder="Enter Confirm Password"></b-form-input>
                    </div>
                    <div class="d-flex justify-content-center gap10">
                        <button class="button" @click.prevent="addNewAdmin">
                            <i class="fa fa-save mr-2"></i>
                            Save
                        </button>
                        <button class="button" @click.prevent="closeModal">
                            <i class="fa fa-ban mr-2"></i>
                            Cancel
                        </button>
                    </div>
                </div>
            </template>
            <template v-if="edit_id">
                <div class="d-flex flex-column" style="gap: 10px;">
                    <div class="d-flex flex-column">
                        <label class="input-label">Full Name: </label>
                        <b-form-input v-model="modal_data_edit.fullname" placeholder="Enter Full Name"></b-form-input>
                    </div>
                    <div class="d-flex flex-column">
                        <label class="input-label">Email: </label>
                        <b-form-input v-model="modal_data_edit.email" placeholder="Enter Email"></b-form-input>
                    </div>
                    <div class="d-flex justify-content-center gap10">
                        <button class="button" @click.prevent="updateAdmin">
                            <i class="fa fa-save mr-2"></i>
                            Save
                        </button>
                        <button class="button" @click.prevent="closeModal">
                            <i class="fa fa-ban mr-2"></i>
                            Cancel
                        </button>
                    </div>
                </div>
            </template>
        </b-modal>
    </div>
</template>


<script>
export default {
    data() {
        return {
            loader: true,
            admins: [],
            modal_title: 'Add New Admin',
            edit_id: null,
            modal_data_add: {
                fullname: null,
                email: null,
                password: null,
                cpassword: null,
            },
            modal_data_edit: {
                fullname: null,
                email: null    
            }
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchAdmins()
        this.loader = false
    },
    methods: {
        async closeModal() {
            this.modal_data_add = {
                fullname: null,
                email: null,
                password: null,
                cpassword: null,
            }
            this.modal_data_edit = {
                fullname: null,
                email: null    
            }
            this.edit_id = null
            this.$bvModal.hide('addEditModal')
            await this.fetchAdmins()
        },
        async addNewAdmin() {
            if (!this.modal_data_add.fullname || !this.modal_data_add.fullname.trim()) {
                this.$toast.show('Fullname is required.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (!this.modal_data_add.email || !this.modal_data_add.email.trim()) {
                this.$toast.show('Email is required.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            var validEmailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

            if (!validEmailRegex.test(this.modal_data_add.email)) {
                this.$toast.show('Enter a valid email address.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                });
                return;
            }
            if (!this.modal_data_add.password || !this.modal_data_add.password.trim()) {
                this.$toast.show('Password is required.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (!this.modal_data_add.cpassword || !this.modal_data_add.cpassword.trim()) {
                this.$toast.show('Confirm password is required.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (this.modal_data_add.password !== this.modal_data_add.cpassword) {
                this.$toast.show('Confirm password is not matching with password.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            const response = await this.$axios({
                method: 'POST',
                url: '/add-admin',
                data: {
                    fullname: this.modal_data_add.fullname,
                    email: this.modal_data_add.email,
                    password: this.modal_data_add.password,
                }
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.closeModal()
        },
        async updateAdmin() {
            if (!this.modal_data_edit.fullname || !this.modal_data_edit.fullname.trim()) {
                this.$toast.show('Fullname is required.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (!this.modal_data_edit.email || !this.modal_data_edit.email.trim()) {
                this.$toast.show('Email is required.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            var validEmailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

            if (!validEmailRegex.test(this.modal_data_edit.email)) {
                this.$toast.show('Enter a valid email address.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                });
                return;
            }
            const response = await this.$axios({
                method: 'POST',
                url: '/update-admin',
                data: {
                    admin_id: this.edit_id,
                    fullname: this.modal_data_edit.fullname,
                    email: this.modal_data_edit.email,
                }
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.closeModal()
        },
        openAddEditModal(data = null) {
            if (data && data.id) {
                this.edit_id = data.id
                this.modal_data_edit.fullname = data.fullname
                this.modal_data_edit.email = data.email
            }
            this.$bvModal.show('addEditModal')
        },
        async fetchAdmins() {
            const response = await this.$axios.get('/fetch-admin')
            this.admins = response.data.admins
        }
    }
}
</script>