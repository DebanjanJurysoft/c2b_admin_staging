<template>
    <div class="customer-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row border">
                <div @click.prevent="changeTab(tab)" class="tab-items" v-for="(tab, tab_index) in  tabs" :key="tab_index" 
                    :class="`w${Math.floor(100 / Number(tabs.length))} ${tab == selected_tab ? 'tab-items-active' : ''}`"
                >
                    <span>{{ tab }}</span>
                </div>
            </div> 
            <div class="d-flex flex-row-reverse py-3">
                <button class="button" @click.prevent="sendMessageToUsers"><i class="mr-2 fa fa-bell-o"></i>Send notification</button>
            </div>
            <div v-if="!users.length" class="p-5 d-flex justify-content-center">
                <span class="text-heading fontSize30">No users found</span>
            </div>
            <div v-else>
                <table class="main-table">
                    <thead>
                        <th class="heading" style="width: 40px !important;">
                            <b-form-checkbox
                                v-model="select_all"
                                @change="selecteAll(select_all)"
                            >
                            </b-form-checkbox>
                        </th>
                        <th class="heading">SL</th>
                        <th class="heading">{{selected_tab == 'VENDOR' ? 'vendor name' : 'customer name'}}</th>
                        <th class="heading" v-if="selected_tab == 'VENDOR'">store name</th>
                    </thead>
                <tbody>
                    <tr
                        v-for="(user, user_index) in users"
                        :key="user_index"
                        class="table-rows">
                        <td style="width: 40px !important;">
                            <b-form-checkbox
                                @change="checkAllSelected"
                                v-model="user.selected"
                            >
                            </b-form-checkbox>
                        </td>
                        <td>{{ user_index + 1 }}</td>
                        <td>{{ user.user }}</td>
                        <td v-if="selected_tab == 'VENDOR'">{{ user.store }}</td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <b-modal id="NotificationModal" size="xl" hide-footer hide-header no-close-on-backdrop>
                <div class="d-flex flex-column">
                    <div class="d-flex justify-content-between">
                        <span class="text-heading fontSize20" style="padding-left: 0px !important;">Notification Details</span>
                        <span class="text-heading fontSize20" style="padding-left: 0px !important;">{{ `Sending to ${selected_users.length == 1 ? `${selected_users.length} user`: `${selected_users.length} users` }` }}</span>
                    </div>
                    <div class="d-flex flex-column">
                        <span class="text-heading fontSize16" style="padding-left: 0px !important;">Notification Title:</span>
                        <b-form-input v-model="title" placeholder="Title"></b-form-input>
                    </div>
                    <div class="d-flex flex-column">
                        <span class="text-heading fontSize16" style="padding-left: 0px !important;">Notification Message:</span>
                        <b-form-textarea
                            v-model="message"
                            placeholder="Notification Message"
                            rows="2"
                            max-rows="2"
                        ></b-form-textarea>
                    </div>
                    <div class="d-flex justify-content-center gap24 pt-4 pb-2">
                        <button class="btn btn-danger" @click.prevent="closeModal"> <i class="fa fa-times mr-2"></i> Close</button>
                        <button class="btn btn-success" @click.prevent="sendNotification"> <i class="fa fa-send mr-2"></i> Send</button>
                    </div>
                </div>
            </b-modal>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            users: [],
            notification_title: 'Testing title',
            notification_message: 'Testing Message',
            loader: true,
            tabs: ['CUSTOMER', 'VENDOR'],
            selected_tab: 'CUSTOMER',
            selected_users: [],
            title: null,
            message: null,
            select_all: false,
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchUsersForNotifications()
        this.loader = false
    },
    methods: {
        selecteAll(change_to) {
            for (const user of this.users) {
                user.selected = change_to
            }
        },
        checkAllSelected() {
            this.select_all = this.users.filter(e => e.selected == true).length == this.users.length
        },
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
            this.$router.push('/login')
        },
        async changeTab(tab) {
            this.loader = true
            this.selected_tab = tab
            await this.fetchUsersForNotifications()
            this.loader = false
        },
        async fetchUsersForNotifications() {
            try {
                const response = await this.$axios.get(`/fetch-users-to-send-notification?user_type=${this.selected_tab}`)
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.users = response.data.users.map(e => {
                    return {
                        user: e.fullname,
                        store: e.store ? e.store.name : null,
                        device_token: e.device_token,
                        selected: false,
                    }
                })
            } catch (error) {
                console.log(error);
            }
        },
        closeModal() {
            this.title = null
            this.message = null
            this.selected_users = []
            this.checkAllSelected()
            this.$bvModal.hide('NotificationModal')
        },
        sendMessageToUsers() {
            if (!this.users.find(e => e.selected == true)) {
                this.$toast.show('No user is selected to send the message.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            this.selected_users = this.users.filter(e => e.selected == true)
            this.$bvModal.show('NotificationModal')
        },
        async sendNotification() {
            try {
                this.loader = false
                if (!this.title || !this.title.trim()) {
                    this.$toast.show('Title is required.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true, 
                        type: 'error'
                    })
                }
                if (!this.message || !this.message.trim()) {
                    this.$toast.show('Message is required.', {
                        duration: 1500,
                        position: 'top-right',
                        keepOnHover: true, 
                        type: 'error'
                    })
                }
                const response = await this.$axios({
                    method: 'POST',
                    url: '/send-notification-to-selected-users',
                    data: {
                        tokens: this.selected_users.map(e => e.device_token),
                        title: this.title,
                        message: this.message
                    }
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true, 
                    type: response.data.status
                })
                await this.fetchUsersForNotifications()
                this.closeModal()
                this.loader = false
            } catch (error) {
                console.log(error);
            }
        }
    }
}
</script>