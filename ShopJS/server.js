const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 5000;

app.use(cors());
app.use(express.json());

let products = [
  { id: 1, name: "Laptop", category: "Electronics", price: 15000 , stock: 5 , brand: "DELL" },
  { id: 2, name: "Shoes", category: "Fashion", price: 260 , stock: 15 , brand: "ECCO" },
  { id: 3, name: "Jacket", category: "Fashion", price: 140.5 , stock: 2 , brand: "Pajak" },
  { id: 4, name: "Beanie", category: "Fashion", price: 79, stock: 50 , brand: "BOSS"  },
  { id: 5, name: "Pillow", category: "Home", price: 24.99 ,stock: 152 , brand: "ZARA HOME"  },
];

let categories = ["Electronics", "Fashion", "Home", "Toys"];

app.get("/products", (req, res) => {
  res.json(products);
});

app.get("/categories", (req, res) => {
    res.json(categories);
});  

app.get("/products/category/:category", (req, res) => {
  const category = req.params.category;
  const filtered_products = products.filter(p => p.category === category);
  res.json(filtered_products);
});

app.get("/products/search", (req, res) => {
    const query = req.query.q.toLowerCase();
    const results = products.filter(p => p.name.toLowerCase().includes(query));
    res.json(results);
});

app.post("/products", (req, res) => {
  const new_product = { id: products.length + 1, ...req.body };
  products.push(new_product);
  res.status(201).json(new_product);
});

app.post("/categories", (req, res) => {
    const new_category = req.body.name;
    if (!categories.includes(new_category)) {
      categories.push(new_category);
      res.status(201).json({ message: "Category posted" });
    } else {
      res.status(400).json({ message: "Category already exists" });
    }
});

app.delete("/products/:name", (req, res) => {
    const product_name = req.params.name.toLowerCase();
    const product_exists = products.some(p => p.name.toLowerCase() === product_name);
  
    if (product_exists) {
      products = products.filter(p => p.name.toLowerCase() !== product_name);
      res.json({ message: `Product '${req.params.name}' deleted` });
    } else {
      res.status(404).json({ message: "Product not found" });
    }
});

app.delete("/categories/:name", (req, res) => {
  const category_name = req.params.name;
  categories = categories.filter(cat => cat !== category_name);
  res.json({ message: "Category deleted" });
});

app.put("/products/:name", (req, res) => {
    const product_name = req.params.name.toLowerCase();
    const product_index = products.findIndex(p => p.name.toLowerCase() === product_name);
  
    if (product_index !== -1) {
      products[product_index] = { ...products[product_index], ...req.body };
      res.json(products[product_index]);
    } else {
      res.status(404).json({ message: "Product not found" });
    }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
