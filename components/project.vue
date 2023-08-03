<template>
    <div class="w-100 apartmentHolder">
        <div class="addApartment card" style="height: 750px;">
            <div class="p-3 text-center">
                <h3>{{ `${!project_id ? 'Add' : 'Update'} Project` }}</h3>
                <div class="p-1">
                    <div class="row align-items-center">
                        <label class="col-4">Project</label>
                        <input type="text" class="col-8" v-model="project_name" placeholder="Project Name">
                    </div>
                </div>
                <div class="p-1">
                    <div class="row align-items-center">
                        <label class="col-4">Blocks</label>
                        <input type="number" class="col-8" v-model="blocks" placeholder="Blocks In The Projects">
                    </div>
                </div>
                <!-- <div style="height: 300px; overflow-x: hidden; overflow: auto;">
                    <div class="p-3 d-flex" v-if="floor_list.length > 0" v-for="(floor, index) in floor_list">
                        <label class="col-6">Units (FL-{{ floor.floors}})</label>
                        <input class="col-4 " @input="changeAll" :disabled="floor.disabled" type="number" v-model="floor.units">
                    </div>
                </div>
                <div>
                    <b-checkbox v-model="same_for_all" @change="sameForAll" v-if="floor_list.length > 0">Same For All</b-checkbox>
                </div> -->
                <div class="p-3">
                    <button class="btn2" @click.prevent="resetForm()" v-if="project_id"><i class="fa fa-ban"></i> CANCEL</button>
                    <button class="btn2" @click.prevent="saveForm()"><i class="fa fa-save"></i> SAVE</button>
                </div>
            </div>
        </div>
        <div class="viewApartment card" style="width: 70%; height: 750px; padding: 30px; overflow-y: scroll;" v-if="!loader && project_list.length > 0">
            <div class="card my-2" style="width: 100%;" v-for="(project, index) in project_list" :key="index">
                <div class="card-body"> 
                    <h5 class="card-title">{{ project.project_name }}</h5>
                    <p class="card-text">Number of Blocks: {{ project.blocks }}</p>
                    <!-- <p class="card-text">Total units: {{ apartment.total_units }}</p> -->
                    <button class="btn2 mr-2" @click.prevent="showData(project)">
                        <i class="fa fa-eye"></i>
                        DATA
                    </button>
                    <button class="btn2 mr-2" @click.prevent="editProject(project.id)"><i class="fa fa-pencil"></i> EDIT</button>
                    <!-- <button class="btn2" @click.prevent="deleteproject(apartment.id)"><i class="fa fa-trash"></i> DELETE</button> -->
                </div>
            </div>
        </div>
        <div v-else-if="loader">
            <div class="h-100 w-100">
                <div class="text-center">
                    <b-spinner variant="primary" label="Text Centered"></b-spinner>
                </div>
            </div>
        </div>
        <div class="viewApartment" v-else>
            <div class="card my-2">
                <div class="card-body">
                    <h5 class="card-title">No Projects found.</h5>
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
            loader: true,
            project_name: null,
            blocks: 0,
            project_id: null,
            project_list: []
        }
    },
    async mounted() { 
        this.loader = true
        await this.fetchProjects()
        this.loader = false
    },
    methods: {
        showData(project) { 
            localStorage.setItem('project', project.id)
            this.$emit('changeTabOnChange', 'BLOCKS')
        },
        editProject(project_id) {
            this.project_id = project_id
            const project = this.project_list.find(e => e.id == project_id)
            this.project_name = project.project_name
            this.blocks = project.blocks
        },
        resetForm() {
            this.project_name = null
            this.blocks = 0
        },
        async fetchProjects() { 
            try {
                const response = await this.$axios.get('/get-project')
                this.project_list = response.data.data
            } catch (error) {
                console.log(error);
            }
        },
        async saveForm() {
            if (this.project_name.trim() == '') {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter project name.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            if (this.blocks.trim() == '' || this.blocks == 0) {
                Swal.fire({
                    position: 'top-end',
                    icon: 'error',
                    title: 'Enter valid blocks.',
                    showConfirmButton: false,
                    timer: 1500
                })
                return
            }
            const response = await this.$axios.post(this.project_id ? '/update-project' : '/add-project', this.project_id ? {
                id: this.project_id,
                project_name: this.project_name,
                blocks: this.blocks
            } : {
                project_name: this.project_name,
                blocks: this.blocks
            })
            Swal.fire({
                position: 'top-end',
                icon: response.data.message.includes('success') ? 'success' : 'error',
                title: response.data.message,
                showConfirmButton: false,
                timer: 1500
            })
            this.fetchProjects()
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
    justify-content: space-evenly;
    display: flex;
}
.addApartment {
    width: 40%;
    float: left;
    margin-right: 30px;
}

.viewApartment {
    width: 60%;
    float: left;
}
</style>