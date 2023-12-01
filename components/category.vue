<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-if="!loader" class="tabs-content">
            <div class="d-flex flex-row w-100" style="gap: 30px">
                <div class="d-flex flex-column w-50" style="gap: 10px;  height: 100% !important; overflow-y: scroll;">
                    <div class="d-flex flex-row align-items-center justify-content-between px-3">
                        <h1 class="heading" style="font-size: 20px; background: none; border: none; color: black;">Categories</h1>
                        <i class="fa fa-refresh text-success" @click.prevent="fetchCategories"></i>
                    </div>
                    <div class="card" v-for="(category, cat_index) in category_list" style="border-radius: 16px; cursor: pointer;" @click.prevent="showCategoryForIndex(cat_index)" >
                        <div class="d-flex flex-row py-3 pl-5 pr-3 justify-content-between align-items-center" :style="cat_index == category_index ? 'border-radius: 16px; border: 2px solid #e74c3c; box-shadow: 0px 0px 12px 0px rgba(0, 0, 0, 0.12);' : ''">
                            <div>
                                <img style="border-radius: 16px; width: 60px !important; object-fit: cover;" :src="category.image" width="100" alt="Image">
                                <span class="heading" style="font-size: 26px; background: none; border: none;" >{{ category.category_name }}</span>
                            </div>
                            <i 
                                v-b-tooltip.hover
                                title="Show Sub-Categories"
                                class="fa fa-sitemap"
                                style="font-size: 20px; background: none; border: none; color: #667085;"
                            ></i>
                        </div>
                    </div>
                </div>
                <div class="d-flex flex-column w-50" style="gap: 10px;  height: 100% !important; overflow-y: scroll;" v-if="category_index != null">
                    <div class="d-flex flex-row align-items-center justify-content-between px-3 mt-3">
                        <h1 class=".text-heading" style="font-size: 18px; background: none; border: none; color: black;">Sub - Categories ({{ sub_category_list.length }})</h1>
                        <div class="d-flex flex-row align-items-center" style="gap: 10px;">
                            <i class="fa fa-refresh text-primary" @click.prevent="fetchSubCategories"></i>
                            <i @click.prevent="openSubCategoryAddingForm" style="font-size: 18px;" class="fa fa-plus-circle text-success cursor-pointer" aria-hidden="true"></i>
                        </div>
                    </div>
                    <div class="d-flex flex-column sub-category-form mb-3" v-if="open_form">
                        <div class="d-flex flex-column" style="gap: 10px">
                            <div class="d-flex flex-row align-items-center justify-content-between">
                                <h1 class="heading" style="font-size: 16px; width: 100% !important; background: none; border: none; color: black;">{{ edit_id ? 'Edit Sub - Category' : 'Add Sub - Category' }}</h1>
                                <i @click.prevent="closeForm" style="font-size: 20px;" class="fa fa-times-circle text-danger cursor-pointer" aria-hidden="true"></i>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <div class="d-flex flex-row" style="gap: 5px">
                                    <b-form-group
                                        label="Category"
                                        class="mb-0 w-75"
                                    >
                                    <b-form-select v-model="selected_category.id" value-field="id" text-field="category_name" disabled :options="category_list"></b-form-select>
                                    </b-form-group>
                                    <div class="d-flex w-25 justify-content-center">
                                        <b-form-group
                                            label="Active"
                                            class="mb-0"
                                        >
                                            <b-form-checkbox size="lg" v-model="selected_subcategory_data.active" switch></b-form-checkbox>
                                        </b-form-group>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Sub - Category Name"
                                    class="mb-0"
                                >
                                    <b-form-input type="text" placeholder="Sub - Category Name" v-model="selected_subcategory_data.sub_category" />
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3">
                                <b-form-group
                                    label="Sub - Category Image File"
                                    class="mb-0"
                                >
                                    <b-form-file @input="changeImage($event)" v-model="selected_subcategory_data.sub_category_file" ref="sub-category-file" class="mb-2"></b-form-file>
                                </b-form-group>
                            </div>
                            <div class="d-flex flex-column px-3" v-if="selected_subcategory_data.image_url">
                                <img style="width: 100px; border-radius: 16px;" :src="selected_subcategory_data.image_url" alt="Image">
                            </div>
                            <div class="d-flex justify-content-center ">
                                <button class="button" @click.prevent="!edit_id ? saveSubCategories() : updateSubCategory()">
                                    {{ edit_id ? 'Update' : 'Create' }}
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="d-flex flex-column" v-if="category_index != null">
                        <div class="d-flex flex-column" style="gap: 10px">
                            <div class="card" style="border-radius: 20px;" v-for="(sub_category, sub_cat_index) in sub_category_list">
                                <div class="d-flex flex-row py-3 pl-3 pr-3 justify-content-between align-items-center">
                                    <div>
                                        <img style="border-radius: 16px; height: 60px !important; width: 60px !important; object-fit: cover;" :src="sub_category.image_url" width="100" alt="Image">
                                        <span class="heading" style="font-size: 20px; background: none; border: none;" >{{ sub_category.name }}</span>
                                    </div>
                                    <div class="d-flex align-items-center">
                                        <i class="fa fa-pencil mr-2 text-primary" @click.prevent="openEdit(sub_category)" aria-hidden="true"></i>
                                        <b-form-checkbox v-model="sub_category.active" @input="updateVisibility(sub_category, sub_category.active)" switch></b-form-checkbox>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    data() {
        return {
            loader: false,
            category_list: [],
            selected_category: null,
            sub_category_list: [],
            selected_subcategory_data: {
                sub_category: null,
                category: null,
                sub_category_file: null,
                active: true,
                image_url: null,
            },
            category_index: null,
            open_form: false,
            edit_id: null,
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchCategories()
        await this.fetchSubCategories()
        this.loader = false
    },
    methods: {
        async openEdit(data) {
            this.edit_id = data.id
            this.selected_subcategory_data.active = data.active
            this.selected_subcategory_data.category = this.category_list[this.category_index]
            this.selected_subcategory_data.sub_category = data.name
            this.selected_subcategory_data.image_url = data.image_url
            this.open_form = true
        },
        async changeImage(event) { 
            this.selected_subcategory_data.image_url = URL.createObjectURL(event)
        },
        async updateVisibility(data, active) {
            this.loader = true
            const form_data = new FormData()
            form_data.append('sub_category_id', data.id)
            form_data.append('sub_category_file', null)
            form_data.append('sub_category_name', data.name)
            form_data.append('active', active)
            const response = await this.$axios.post('/edit-sub-category-for-admin', form_data, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.fetchSubCategories()
            this.loader = false
        },
        async updateSubCategory() {
            this.loader = true
            const form_data = new FormData()
            form_data.append('sub_category_id', this.edit_id)
            form_data.append('sub_category_file', this.selected_subcategory_data.sub_category_file)
            form_data.append('sub_category_name', this.selected_subcategory_data.sub_category)
            form_data.append('active', this.selected_subcategory_data.active)
            const response = await this.$axios.post('/edit-sub-category-for-admin', form_data, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.fetchSubCategories()
            this.closeForm()
            this.loader = false
        },
        async saveSubCategories() {
            this.loader = true
            if (!this.selected_subcategory_data.sub_category) {
                this.$toast.show('Enter a sub category name.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                this.loader = false
                return
            }
            if (!this.selected_subcategory_data.sub_category_file) {
                this.$toast.show('Select a sub category file.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                this.loader = false
                return
            }
            const form_data = new FormData()
            form_data.append('sub_category_file', this.selected_subcategory_data.sub_category_file)
            form_data.append('category', JSON.stringify(this.selected_subcategory_data.category))
            form_data.append('sub_category_name', this.selected_subcategory_data.sub_category)
            form_data.append('active', this.selected_subcategory_data.active)
            const response = await this.$axios.post('/add-sub-category-for-admin', form_data, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            })
            this.$toast.show(response.data.message, {
                duration: 1500,
                position: 'top-right',
                keepOnHover: true,
                type: response.data.status
            })
            await this.fetchSubCategories()
            this.closeForm()
            this.loader = false
        },
        closeForm() {
            this.selected_subcategory_data = {
                sub_category: null,
                category: null,
                sub_category_file: null,
                active: true
            },
            this.open_form = false
        },
        openSubCategoryAddingForm() {
            this.selected_subcategory_data.category = this.category_list[this.category_index]
            this.open_form = true
        },
        async showCategoryForIndex(index) {
            this.category_index = index
            this.selected_category = this.category_list[this.category_index]
            await this.fetchSubCategories()
        },
        async fetchCategories() {
            this.loader = true
            try {
                const path = '/get-categories-and-services'
                const response = await this.$axios.get(path)
                this.category_list = response.data.categories
                this.$emit('reloadDashboard')
            } catch (error) {
               console.log(error); 
            }
            this.loader = false
        },
        async fetchSubCategories() {
            this.loader = true
            try {
                const selectedCategory = this.category_list[this.category_index]
                const path = `/fetch-sub-category-for-admin?category=${selectedCategory.category_name.includes('&') ? selectedCategory.category_name.replace('&', '%26') : selectedCategory.category_name}`
                const response = await this.$axios.get(path)
                this.sub_category_list = response.data.subCategories
                this.$emit('reloadDashboard')
            } catch (error) {
               console.log(error); 
            }
            this.loader = false
        }
    }
}
</script>


<style>
.sub-category-form {
    /* border: 2px solid #fe988d; */
    height: max-content;
    background: #FDEDEC;
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0px 0px 12px 0px rgba(0, 0, 0, 0.12);
}
</style>