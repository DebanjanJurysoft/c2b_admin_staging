<template>
  <div class="order-container">
    <div v-if="loader" class="loader">
      <Loader />
    </div>
    <div v-if="!loader" class="order-tabs">
      <div
        class="tab-items"
        @click.prevent="changeTab(index)"
        :class="selected_tab.id == tab.id ? 'tab-items-active' : ''"
        v-for="(tab, index) in tabs"
        :key="index"
      >
        <span>{{ tab.text }}</span>
      </div>
    </div>
    <div v-if="!loader" class="tabs-content">
      <div class="d-flex flex-row align-items-center">
        <div class="w-75 d-flex flex-row align-items-center" style="gap: 10px">
          <label class="mr-3">Rows:</label>
          <b-form-select
            style="width: 100px"
            v-model="per_page"
            :options="per_page_options"
          ></b-form-select>
          <button
            v-b-tooltip.hover
            title="Reload"
            class="button"
            @click.prevent="changeTab(tabs.indexOf(selected_tab))"
          >
            <i class="fa fa-refresh"></i>
          </button>
        </div>
        <div class="w-25">
          <!-- top pagination  -->
          <Pagination
            @changePage="changePage"
            :data_list="orders"
            :per_page="per_page"
            :total_rows="order_total"
            :page="page"
          />
        </div>
      </div>
      <Table
        @openSpecific="openSpecific"
        @openDetails="openDetails"
        :headings="order_headings"
        :data_rows="orders"
        :file_name="`${selected_tab.name}_list.csv`"
        :page="page"
        :rows="per_page"
      />
      <Pagination
        @changePage="changePage"
        :data_list="orders"
        :per_page="per_page"
        :total_rows="order_total"
        :page="page"
      />
      <SidebarComponent
        @openDetails="openDetails"
        :visible="show_details"
        :title="'Product Details'"
        :product_details="product_details"
      />
    </div>
    <b-modal
      id="orderDetailsModal" 
      hide-footer 
      lazy
      size="xl"
      header-bg-variant="dark"
      header-text-variant="light"
      title="Order details" 
    >
      <table class="main-table" v-if="order_details">
        <thead>
          <th class="heading">SL</th>
          <th class="heading">Product</th>
          <th class="heading">Category</th>
          <th class="heading">Quantity</th>
          <th class="heading">Unit Price</th>
          <th class="heading">Sub Total Price</th>
          <th class="heading d-flex flex-row align-items-center gap10 justify-content-center" v-if="selected_tab.id == 4">
            Select All <b-form-checkbox v-model="selectAll" @change="() => {
              order_details.forEach(order => order.checked = selectAll)
            }"></b-form-checkbox>
          </th>
        </thead>
        <tbody>
          <tr class="table-rows" v-for="(order, order_index) in order_details" :key="order_index">
            <td>{{ order_index + 1 }}</td>
            <td>{{ order.product.name }}</td>
            <td>{{ order.category_table_association.category_name }}</td>
            <td>X {{ order.quantity }}</td>
            <td>
              {{ `₹ ${(
                parseFloat(order.product.price).toFixed(2)
              ).toLocaleString("en-IN")}` }}
            </td>
            <td>
              {{ `₹ ${(
                parseFloat(Number(order.product.price) * Number(order.quantity)).toFixed(2)
              ).toLocaleString("en-IN")}` }}
            </td>
            <td v-if="selected_tab.id == 4" class="text-center">
              <b-form-checkbox v-model="order.checked" @change="selectAll = order_details.filter(e => e.checked == true).length == order_details.length"></b-form-checkbox>
            </td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="table-rows">
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td>Total Price</td>
            <td>{{ `₹ ${(parseFloat(findTotal(order_details)).toFixed(2)).toLocaleString("en-IN")}` }}</td>
            <td v-if="selected_tab.id == 4" class="d-flex gap10 justify-content-center">
              <button class="btn btn-success btn-sm"
                v-b-tooltip.hover
                title="Accept"
                @click.prevent="accept_reject(order_details)"
              ><i class="fa fa-check mr-2"></i>Accept</button>
            </td>
          </tr>
        </tfoot>
      </table>
    </b-modal>
  </div>
</template>
<script>
export default {
  props: ["searchText"],
  data() {
    return {
      loader: false,
      selectAll: true,
      selectedOrder: null,
      selected_tab: {
        id: 1,
        name: "accepted_orders",
        text: "Accepted orders",
      },
      tabs: [
        {
          id: 4,
          name: "pending_orders",
          text: "pending orders",
        },
        {
          id: 1,
          name: "accepted_orders",
          text: "accepted orders",
        },
        {
          id: 2,
          name: "rejected_orders",
          text: "rejected orders",
        },
        {
          id: 3,
          name: "delivered_products",
          text: "delivered orders",
        },
      ],
      orders: [],
      order_headings: [],
      order_total: 0,
      accepted_orders: [],
      accepted_order_heading: [
        {
          name: "vendor name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "store name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "order id",
          icon: "bx bxs-package",
          onclick: true,
        },
        {
          name: "order status",
          icon: "bx bxs-package",
          type: "DROPDOWN",
          onclick: true,
          onclick_emit: 'changeStatus',
          dropdown_data: [
            {
              value: null,
              text: "Accept or reject",
            },
            {
              value: true,
              text: "Accept",
            },
            {
              value: false,
              text: "Reject",
            },
          ],

        },
        {
          name: "product list",
          icon: "fa fa-shopping-basket",
          type: 'a',
          onclick: true,
          onclick_emit: 'show_products'
        },
        {
          name: "date",
          icon: "fa fa-calendar-o",
        },
        {
          name: "time",
          icon: "fa fa-clock-o",
        },
      ],
      pending_order_total: 0,
      pending_orders: [],
      pending_order_heading: [
        {
          name: "vendor name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "store name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "order id",
          icon: "bx bxs-package"
        },
        // {
        //   name: "accept / reject",
        //   icon: "bx bxs-package",
        //   type: "DROPDOWN",
        //   onclick: true,
        //   onclick_emit: 'accept_reject',
        //   dropdown_data: [
        //     {
        //       value: null,
        //       text: "Accept or reject",
        //     },
        //     {
        //       value: true,
        //       text: "Accept",
        //     },
        //     {
        //       value: false,
        //       text: "Reject",
        //     },
        //   ],
        // },
        {
          name: "product list",
          icon: "fa fa-shopping-basket",
          type: 'a',
          onclick: true,
          onclick_emit: 'show_products'
        },
        {
          name: "date",
          icon: "fa fa-calendar-o",
        },
        {
          name: "time",
          icon: "fa fa-clock-o",
        },
      ],
      rejected_order_total: 0,
      rejected_orders: [],
      rejected_order_heading: [
        {
          name: "vendor name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "store name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "order id",
          icon: "bx bxs-package",
          onclick: true,
        },
        {
          name: "product list",
          icon: "fa fa-shopping-basket",
          type: 'a',
          onclick: true,
          onclick_emit: 'show_products'
        },
        {
          name: "date",
          icon: "fa fa-calendar-o",
        },
        {
          name: "time",
          icon: "fa fa-clock-o",
        },
      ],
      delivered_order_total: 0,
      delivered_orders: [],
      delivered_order_heading: [
        {
          name: "vendor name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "store name",
          icon: "fa fa-shopping-basket",
        },
        {
          name: "product list",
          icon: "fa fa-shopping-basket",
          type: 'a',
          onclick: true,
          onclick_emit: 'show_products'
        },
        {
          name: "order id",
          icon: "bx bxs-package",
          onclick: true,
        },
        {
          name: "date",
          icon: "fa fa-calendar-o",
        },
        {
          name: "time",
          icon: "fa fa-clock-o",
        },
      ],
      accepted_order_total: 0,
      per_page: 5,
      page: 1,
      per_page_options: Array.from(Array(15).keys()).map((e) => e + 1),
      product_details: null,
      show_details: false,
      order_status_list: [],
      order_details: null
    };
  },
  async mounted() {
    await this.mountedMethod();
    this.changeTab(0);
  },
  watch: {
    per_page() {
      this.changePage(this.page);
    },
    searchText(val) {
      clearTimeout(this.timer)
      this.timer = setTimeout(async () => {
        this.loader = true
        await this.changeTab(this.tabs.indexOf(this.selected_tab))
        this.loader = false
      }, 300);
    }
  },
  methods: {
    findTotal(data) {
      let total = 0
      for (const order of data) {
        total = total + Number(order.product.price) * Number(order.quantity)
      }
      return total
    },
    openModalForOrderDetails(data) {
      this.selectedOrder = data.id
      this.order_details = data.order_details.map(e => {
        return {
          ...e,
          checked: true
        }
      })
      this.$bvModal.show('orderDetailsModal')
    },
    async updateStatus(order_id, status_id) {
      try {
        this.loader = true;
        const data = {
          order_id,
          status_id,
        };
        const response = await this.$axios.post("/change-order-status", data);
        this.$toast.show(response.data.message, {
          duration: 1500,
          position: "top-right",
          keepOnHover: true,
          type: response.data.status,
        });
        await this.mountedMethod();
        this.loader = false;
      } catch (error) {
        console.log(error);
      }
    },
    async fetchorderStatus() {
      try {
        const response = await this.$axios.get("/fetch-order-status");
        if (response.data.code == 401) {
          await this.logout();
        }
        this.order_status_list = response.data.order_statuses.map((e) => {
          return {
            value: e.id,
            text: e.status_name,
          };
        });
        this.accepted_order_heading.forEach((e) => {
          if (e.name == "order status") {
            e["dropdown_data"] = this.order_status_list;
          }
        });
      } catch (error) {
        console.log(error);
      }
    },
    async openDetails(data) {
      const index = parseInt(data);
      this.product_details = {};
      if (!this.show_details) {
        const selectedData = this.orders[index];
        this.product_details = {
          product_image:
            "https://close2buy-dev.jurysoftprojects.com/uploads/categories/Food.svg",
          product_name: selectedData["product name"],
          product_price: selectedData["unit price"],
          product_quantity: selectedData["quantity"],
          product_id: selectedData["product id"],
          product_desc: selectedData.full_data.product.description,
          product_colors: selectedData.full_data.product.color
            ? [
                {
                  name: selectedData.full_data.product.color,
                },
              ]
            : null,
          product_sizes: selectedData.full_data.product.size
            ? [
                {
                  name: selectedData.full_data.product.size[0].toUpperCase(),
                },
              ]
            : null,
          product_specification: selectedData.full_data.product.specifications
            ? selectedData.full_data.product.specifications.split(",")
            : null,
          product_negotiation: selectedData.full_data.negotiation
            ? {
                heading: "Negotiation",
                icon: "fa fa-commenting-o",
                text: "Negotiate for the best deal! Chat with the seller to discuss offers, discounts, and customizations before making your purchase.",
              }
            : null,
          downloadInvoiceUrl: `${this.$axios.defaults.baseURL}/invoice?order_id=${selectedData.full_data.order.id}&authorization=${this.$auth.$storage._state["_token.local"]}`,
          downloadInvoicefileName: `Invoice-${selectedData.full_data.order.id}.pdf`,
          downloadInvoiceText: `Invoice (${selectedData["order id"]})`,
          product_delivery_types: [
            {
              text: "SELF PICKUP",
            },
            {
              text: "CLOSE2BUY DELIVERY",
            },
            {
              text: "SELLER DELIVERY",
            },
          ].map((e) => {
            if (e.text == selectedData["delivery type"]) {
              return {
                value: true,
                ...e,
              };
            } else {
              return {
                value: false,
                ...e,
              };
            }
          }),
        };
      }
      this.show_details = !this.show_details;
    },
    async changePage(page_no) {
      this.loader = true
      this.page = page_no;
      switch (this.selected_tab.id) {
        case 1:
          await this.fetchAcceptedOrders();
          this.order_headings = this.accepted_order_heading;
          this.orders = this.accepted_orders;
          this.order_total = this.accepted_order_total;
          break;
        case 2:
          await this.fetchRejectedOrders();
          this.order_headings = this.rejected_order_heading;
          this.orders = this.rejected_orders;
          this.order_total = this.rejected_order_total;
          break;
        case 3:
          await this.fetchDeliveredOrders();
          this.order_headings = this.delivered_order_heading;
          this.orders = this.delivered_orders;
          this.order_total = this.delivered_order_total;
          break;
        case 4:
          await this.fetchPendingOrders();
          this.order_headings = this.pending_order_heading;
          this.orders = this.pending_orders;
          this.order_total = this.pending_order_total;
          break;
      }
      window.scrollTo(0, 0);
      this.loader = false;
    },
    async openSpecific(data) {
      if (data.type == "accept_reject") {
        if (
          data.data["accept / reject"] !== null &&
          data.data["accept / reject"] !== undefined
        )
          await this.accept_reject(data);
      }
      if (data.type == "changeStatus") {
        await this.updateStatus(data.data.id, data.data["order status"]);
      }
      if (data.type == "show_products") {
        this.openModalForOrderDetails(data.data.full_data)
      }
    },
    async accept_reject(data) {
      this.loader = true;
      this.$bvModal.hide('orderDetailsModal')
      const accepted_order_ids = data.filter(e => e.checked == true).map(e => e.id)
      const rejected_order_ids = data.filter(e => e.checked == false).map(e => e.id)
      const payload_data = {
        order_id: this.selectedOrder,
        accepted_order_ids: accepted_order_ids.length ? accepted_order_ids : null,
        rejected_order_ids: rejected_order_ids.length ? rejected_order_ids : null
      }
      const response = await this.$axios.post("/accept-reject-order-vendor", payload_data);
      this.$toast.show(response.data.message, {
        duration: 1500,
        position: "top-right",
        keepOnHover: true,
        type: response.data.status,
      });
      await this.mountedMethod();
      this.changeTab(1);
      this.selectAll = false
      this.loader = false;
    },
    async mountedMethod(tab = null) {
      this.loader = true;
      switch (tab) {
        case null:
          await this.fetchPendingOrders();
          await this.fetchAcceptedOrders();
          await this.fetchRejectedOrders();
          await this.fetchDeliveredOrders();
          await this.fetchorderStatus();
          break;

        case 1:
          await this.fetchAcceptedOrders();
          await this.fetchorderStatus();
          break;

        case 2:
          await this.fetchRejectedOrders();
          break;

        case 3:
          await this.fetchDeliveredOrders();
          break;

        case 4:
          await this.fetchPendingOrders();
          break;

        default:
          break;
      }
      this.$emit("reloadDashboard");
      this.loader = false;
    },
    async changeTab(index) {
      this.page = 1;
      this.selected_tab = this.tabs[index];
      await this.mountedMethod();
      await this.mountedMethod(this.selected_tab.id);
      switch (this.selected_tab.id) {
        case 1:
          this.order_headings = this.accepted_order_heading;
          this.orders = this.accepted_orders;
          this.order_total = this.accepted_order_total;
          break;
        case 2:
          this.order_headings = this.rejected_order_heading;
          this.orders = this.rejected_orders;
          this.order_total = this.rejected_order_total;
          break;
        case 3:
          this.order_headings = this.delivered_order_heading;
          this.orders = this.delivered_orders;
          this.order_total = this.delivered_order_total;
          break;
        case 4:
          this.order_headings = this.pending_order_heading;
          this.orders = this.pending_orders;
          this.order_total = this.pending_order_total;
          break;

        default:
          break;
      }
      this.loader = false;
    },
    async logout() {
      await this.$auth.logout();
      this.$router.push("/login");
    },
    async fetchPendingOrders() {
      let query = `/fetch-orders-admin?page=${
        this.page ? this.page : 1
      }&per_page=${this.per_page}`;
      if (this.searchText && this.searchText != "") {
        query = query + `&q=${this.searchText}`;
      }
      const response = await this.$axios.get(query);
      if (response.data.code == 401) {
        await this.logout();
      }
      this.pending_order_total = response.data.total;
      this.pending_orders = response.data.orders.map((order) => {
        const vendor = order.order_details[0].product.vendor
        return {
          "vendor name": vendor.fullname,
          "store name": vendor.store.name,
          "order id": order.ord_id,
          "accept / reject": null,
          'product list': `${order.order_details.length} ${order.order_details.length == 1 ? 'Product' : 'Products'}`,
          "total price": `₹ ${(
            parseFloat(order.order_amount).toFixed(2)
          ).toLocaleString("en-IN")}`,
          date: order.createdAt
            ? new Date(order.createdAt).toLocaleDateString()
            : "N/A",
          time: order.createdAt
            ? new Date(order.createdAt).toLocaleTimeString()
            : "N/A",
          id: order.id,
          full_data: order,
        };
      });
      this.tabs.forEach((e) => {
        if (e.name == "pending_orders") {
          e.text = `pending orders (${this.pending_order_total})`;
        }
      });
    },
    async fetchAcceptedOrders() {
      try {
        let query = `/fetch-orders-admin?page=${
          this.page ? this.page : 1
        }&per_page=${this.per_page}&accepted=true`;
        if (this.searchText && this.searchText != "") {
          query = query + `&q=${this.searchText}`;
        }
        const response = await this.$axios.get(query);
        if (response.data.code == 401) {
          await this.logout();
        }
        this.accepted_order_total = response.data.total;
        const data = response.data.orders.map((order) => {
          const vendor = order.order_details[0].product.vendor
          const order_details = order.order_details[0]
          return {
            "vendor name": vendor.fullname,
            "store name": vendor.store.name,
            "order id": order.ord_id,
            'order status': order_details.order_status_id,
            'product list': `${order.order_details.length} ${order.order_details.length == 1 ? 'Product' : 'Products'}`,
            "total price": `₹ ${(
              parseFloat(order.order_amount).toFixed(2)
            ).toLocaleString("en-IN")}`,
            date: order.createdAt
              ? new Date(order.createdAt).toLocaleDateString()
              : "N/A",
            time: order.createdAt
              ? new Date(order.createdAt).toLocaleTimeString()
              : "N/A",
            id: order.id,
            full_data: order,
          };
        });
        this.accepted_orders = [];
        this.accepted_orders = await Promise.all(data);
        this.tabs.forEach((e) => {
          if (e.name == "accepted_orders") {
            e.text = `accepted orders (${this.accepted_order_total})`;
          }
        });
      } catch (error) {
        console.log(error);
      }
    },
    async fetchRejectedOrders() {
      try {
        let query = `/fetch-orders-admin?page=${
          this.page ? this.page : 1
        }&per_page=${this.per_page}&status=13&accepted=false`;
        if (this.searchText && this.searchText != "") {
          query = query + `&q=${this.searchText}`;
        }
        const response = await this.$axios.get(query);
        if (response.data.code == 401) {
          await this.logout();
        }
        this.rejected_order_total = response.data.total;
        this.rejected_orders = response.data.orders.map((order) => {
          const vendor = order.order_details[0].product.vendor
          return {
            "vendor name": vendor.fullname,
            "store name": vendor.store.name,
            "order id": order.ord_id,
            'product list': `${order.order_details.length} ${order.order_details.length == 1 ? 'Product' : 'Products'}`,
            "total price": `₹ ${(
              parseFloat(order.order_amount).toFixed(2)
            ).toLocaleString("en-IN")}`,
            date: order.createdAt
              ? new Date(order.createdAt).toLocaleDateString()
              : "N/A",
            time: order.createdAt
              ? new Date(order.createdAt).toLocaleTimeString()
              : "N/A",
            id: order.id,
            full_data: order,
          };
        });
        this.tabs.forEach((e) => {
          if (e.name == "rejected_orders") {
            e.text = `rejected orders (${this.rejected_order_total})`;
          }
        });
      } catch (error) {
        console.log(error);
      }
    },
    async fetchDeliveredOrders() {
      let query = `/fetch-orders-admin?page=${
        this.page ? this.page : 1
      }&per_page=${this.per_page}&status=4&accepted=true`;
      if (this.searchText && this.searchText != "") {
        query = query + `&q=${this.searchText}`;
      }
      const response = await this.$axios.get(query);
      if (response.data.code == 401) {
        await this.logout();
      }
      this.delivered_order_total = response.data.total;
      this.delivered_orders = response.data.orders.map((order) => {
        const vendor = order.order_details[0].product.vendor
        return {
          "vendor name": vendor.fullname,
          "store name": vendor.store.name,
          "order id": order.ord_id,
          'product list': `${order.order_details.length} ${order.order_details.length == 1 ? 'Product' : 'Products'}`,
          "total price": `₹ ${(
            parseFloat(order.order_amount).toFixed(2)
          ).toLocaleString("en-IN")}`,
          date: order.createdAt
            ? new Date(order.createdAt).toLocaleDateString()
            : "N/A",
          time: order.createdAt
            ? new Date(order.createdAt).toLocaleTimeString()
            : "N/A",
          id: order.id,
          full_data: order,
        };
      });
      this.tabs.forEach((e) => {
        if (e.name == "delivered_products") {
          e.text = `delivered orders (${this.delivered_order_total})`;
        }
      });
    },
  },
};
</script>
