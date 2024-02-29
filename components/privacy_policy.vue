<template>
    <div v-if="loader" class="loader">
        <Loader />
    </div>
    <div v-else class="d-flex flex-column pl-4 pr-5 pt-1">
        <div class="d-flex flex-row border">
            <div @click.prevent="changeTab(tab)" class="tab-items" v-for="(tab, tab_index) in  tabs" :key="tab_index" 
                :class="`w${Math.floor(100 / Number(tabs.length))} ${tab == selected_tab ? 'tab-items-active' : ''}`"
            >
                <span>{{ tab }}</span>
            </div>
        </div>  
        <div class="d-flex flex-column p-3 gap16" v-if="selected_tab == 'privacy policy'">
            <div class="w100">
                <div class="d-flex flex-row align-items-center gap16">
                    <span class="text-heading" style="width: 20% !important; padding-left: 0px;">Privacy Policy: </span>
                    <b-form-select @change="fetchStaticFile" class="w20" :options="type_list" v-model="selected_type"></b-form-select>
                    <b-form-file
                    class="w50"
                    v-model="privacy_policy"
                    @input="show_privacy_policy($event)"
                    accept=".pdf, .docs"
                    placeholder="Choose the file for Privacy Policy"
                    ></b-form-file>
                    <div class="d-flex flex-row py-3 justify-content-center w10">
                        <button @click.prevent="saveStaticFiles" class="button"><i class="fa fa-save mr-2"></i> {{button_text}}</button>
                    </div>
                </div>
            </div>
            <div class="w100" style="overflow: hidden !important;" v-if="privacy_policy_link || termsndconditions_link">  
                <iframe :src="privacy_policy_link" class="w100" style="height: 700px !important; max-height: 700px !important; min-height: 700px !important;" frameborder="0"></iframe>
            </div>
        </div>
        <div class="d-flex flex-column p-3 gap16" v-if="selected_tab == 'terms & conditions'">
            <div class="w100">
                <div class="d-flex flex-row align-items-center gap16">
                    <span class="text-heading" style="width: 40% !important; padding-left: 0px;">Terms & Conditions: </span>
                    <b-form-select @change="fetchStaticFile" class="w20" :options="type_list" v-model="selected_type"></b-form-select>
                    <b-form-file
                    class="w50"
                    v-model="termsndconditions"
                    @input="show_terms_and_conditions($event)"
                    accept=".pdf, .docs"
                    placeholder="Choose the file for Terms & Conditions"
                    ></b-form-file>
                    <div class="d-flex flex-row py-3 justify-content-center w10">
                        <button @click.prevent="saveStaticFiles" class="button"><i class="fa fa-save mr-2"></i> {{button_text}}</button>
                    </div>
                </div>
            </div>
            <div class="w100" style="overflow: hidden !important;" v-if="privacy_policy_link || termsndconditions_link">  
                <iframe :src="termsndconditions_link" class="w100" style="height: 700px !important; max-height: 700px !important; min-height: 700px !important;" frameborder="0"></iframe>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            privacy_policy: null,
            privacy_policy_link: null,
            termsndconditions: null,
            termsndconditions_link: null,
            selected_tab: 'privacy policy',
            type_list: [
                {
                    text: 'ALL',
                    value: null,
                }, {
                    text: 'CUSTOMER',
                    value: 'CUSTOMER',
                }, {
                    text: 'VENDOR',
                    value: 'VENDOR',
                }
            ],
            selected_type: null,
            tabs: [
                'privacy policy',
                'terms & conditions',
            ],
            button_text: 'SAVE',
            loader: false
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchStaticFile()
        this.loader = false
    },
    methods: {
        show_privacy_policy(event) {
            this.privacy_policy_link = URL.createObjectURL(event)
        },
        show_terms_and_conditions(event) {
            this.termsndconditions_link = URL.createObjectURL(event)
        },
        async changeTab(tab) {
            this.loader = true
            this.selected_tab = tab
            await this.fetchStaticFile()
            this.loader = false
        },
        async saveStaticFiles() {
            this.loader = true
            try {
                const formData = new FormData()
                formData.append('name', this.selected_tab.toUpperCase())
                if (this.selected_type) {
                    formData.append('for_user_type', this.selected_type.toUpperCase())
                }
                if (this.selected_tab == 'privacy policy') {
                    formData.append('file', this.privacy_policy)
                }
                if (this.selected_tab == 'terms & conditions') {
                    formData.append('file', this.termsndconditions)
                }
                const response = await this.$axios({
                    method: 'POST',
                    url: '/save-static-file',
                    data: formData
                })
                if (response.data.code == 401) {
                    await this.logout()
                }
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                await this.fetchStaticFile()
            } catch (error) {
                console.log(error);
            }
            this.loader = false
        },
        async fetchStaticFile() {
            let path = `/fetch-static-file/${this.selected_tab.toUpperCase()}`
            if (this.selected_type) {
                path = `${path}?for_user_type=${this.selected_type.toUpperCase()}`
            }
            const response = await this.$axios.get(path)
            if (response.data.code == 401) {
                await this.logout()
            }
            if (this.selected_tab == 'privacy policy') {
                this.privacy_policy_link = response.data.file_url
                }
                if (this.selected_tab == 'terms & conditions') {
                this.termsndconditions_link = response.data.file_url
                }
        },
        async logout() {
            localStorage.removeItem('token')
            // localStorage.removeItem('refreshToken')
            this.$router.push('/login')
        },
    }
}
</script>

