<template>
    <div class="category-container">
        <div v-if="loader" class="loader">
            <Loader />
        </div>
        <div v-else class="px-3">
            <div class="d-flex flex-row-reverse pb-3">
                <button class="button" @click.prevent="openModal">
                    <i class="fa fa-plus mr-2"></i>
                    Add Category
                </button>
            </div>
            <table class="table table-hover" v-if="category_list.length == 0">
                <tr class="text-center">
                    No Record Found
                </tr>
            </table>
            <table class="table table-hover" v-if="category_list.length">
                <thead>
                    <th style="text-transform: uppercase;">SL No.</th>
                    <th style="text-transform: uppercase;">category</th>
                    <th style="text-transform: uppercase;">image</th>
                    <th style="text-transform: uppercase; text-align: center; width: 150px !important;">action</th>
                </thead>
                <tbody>
                    <tr v-for="(category, category_index) in category_list">
                        <td>{{ category_index + 1 }}</td>
                        <td>{{ category.category_name }}</td>
                        <td>
                            <img width="40" :src="category.image" :alt="category.category_name">
                        </td>
                        <td>
                            <div class="d-flex justify-content-center">
                                <button @click.prevent="openModal(category)" class="button bg-warning">
                                    <i class="fa fa-pencil mr-2"></i>
                                    EDIT
                                </button>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <!-- Add Category Modal -->
        <b-modal id="addCategoryModal" :title="modalTitle" hide-footer centered hide-header no-close-on-backdrop>
            <div class="d-flex flex-column">
                <div class="d-flex flex-column py-2">
                    <span>Category Name: </span>
                    <b-form-input v-model="category_form.category_name" placeholder="Category Name"></b-form-input>
                </div>
                <div class="d-flex flex-column py-2">
                    <span>Category Image: </span>
                    <b-form-file @change="handleFile($event)" v-model="category_form.category_image" plain></b-form-file>
                </div>
                <div class="d-flex flex-column py-2" v-if="category_form.category_image_url">
                    <img width="120" :src="category_form.category_image_url" :alt="category_form.category_name">
                    <button class="button bg-danger"><i class="fa fa-trash mr-2"></i>Remove</button>
                </div>
                <div class="d-flex justify-content-center gap10">
                    <button class="button bg-danger" @click.prevent="CloseModal">
                        <i class="fa fa-ban mr-2"></i>
                        Close
                    </button>
                    <button @click.prevent="saveCategoryData" class="button bg-success">
                        <i class="fa fa-save mr-2"></i>
                        Save
                    </button>
                </div>
            </div>
        </b-modal>
    </div>
</template>


<script>
export default {
    data() {
        return {
            loader: false,
            category_list: [],
            modalTitle: 'Add Category',
            category_form: {
                category_id: null,
                category_name: null,
                category_image: null,
                category_image_url: null
            }
        }
    },
    async mounted() {
        this.loader = true
        await this.fetchCategories()
        this.loader = false
    },
    methods: {
        async handleFile(e) {
            this.category_form.category_image_url = URL.createObjectURL(e.target.files[0])
        },
        async fetchCategories() {
            try {
                const path = '/get-categories-and-services'
                const response = await this.$axios.get(path)
                this.category_list = response.data.categories
            } catch (error) {
                console.log(error);
            }
        },
        async CloseModal() {
            this.$bvModal.hide('addCategoryModal')
            await this.fetchCategories()
            this.category_form = {
                category_id: null,
                category_name: null,
                category_image: null,
                category_image_url: null
            }
        },
        openModal(data = null) {
            console.log(data);
            this.$bvModal.show('addCategoryModal')
            this.modalTitle = !data ? 'Add Category' : 'Update Category'
            this.category_form = {
                category_id: data ? data.id : null,
                category_name: data ? data.category_name : null,
                category_image: null,
                category_image_url: data ? data.image : null
            }
        },
        async createNewCategory() {
            try {
                const formData = new FormData()
                formData.append('category_name', this.category_form.category_name)
                formData.append('category_image', this.category_form.category_image)
                const response = await this.$axios({
                    method: 'post',
                    url: '/create-category',
                    data: formData
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.CloseModal()
            } catch (error) {
                console.log(error);
            }
        },
        async updateCategory() {
            try {
                const formData = new FormData()
                formData.append('category_id', this.category_form.category_id)
                formData.append('category_name', this.category_form.category_name)
                formData.append('category_image', this.category_form.category_image)
                const response = await this.$axios({
                    method: 'post',
                    url: '/update-category',
                    data: formData
                })
                this.$toast.show(response.data.message, {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: response.data.status
                })
                this.CloseModal()
            } catch (error) {
                console.log(error);
            }
        },
        async saveCategoryData() {
            if (!this.category_form.category_name) {
                this.$toast.show('Category name is mandatory.', {
                    duration: 1500,
                    position: 'top-right',
                    keepOnHover: true,
                    type: 'error'
                })
                return
            }
            if (!this.category_form.category_id) {
                await this.createNewCategory()
            } else if (this.category_form.category_id) {
                await this.updateCategory()
            }
        }
    }
}
</script>