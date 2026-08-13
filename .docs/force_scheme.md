# Algoritmo de Frutcherman-Reingold
El esquema de Frutcherman-Reingold permite separar los nodos usando fuerzas ficticias para acomodarlos. Las ecuaciones de repulsión-atracción son:

$$
F_R = \frac{\ell^2}{r} \hat{r}, \quad F_A = - \frac{r^2}{\ell} \hat{r}
$$

Donde $\hat{r}$ es el vector unitario que va desde el otro nodo hacia el actual. Podemos verificar que estas ecuaciones equilibran las fuerzas cuando $r = \ell$.

## ¿Cuánto es $\ell$?
Este esquema busca repartir el área disponible $A$ entre los $N$ nodos que los conforman. El área por nodo $A_n$ se define como:

$$
A_n = \frac{A}{N}
$$

FR asume que el área es un cuadrado de lado $\ell$ para que la distancia entre dos nodos adyacentes sea $\ell$ también:

$$
\begin{aligned}
    A_n &= \ell^2 \\
    \ell &= \sqrt{A_n} = \sqrt{\frac{A}{N}} \implies k \sqrt{\frac{A}{N}}
\end{aligned}
$$

Este $k$ es un factor de escala arbitrario.

## ¿Cuánto es $k$?
Una forma de asumir el valor de $k$ es usando empaquetado hexagonal: cada nodo ocupa un círculo de radio $\ell/2$ para que los circulos se empaqueten y así la distancia entre nodos sea de $\ell$. La densidad del área cubierta sigue el valor de $\eta$ que es:

$$
\eta = \frac{\pi}{\sqrt{12}} \approx 0.907
$$

Aplicando esto para $A_n$ obtenemos:

$$
\begin{aligned}
    A_n &= \frac{\eta A}{N} = \frac{\pi \ell^2}{4} \\
    \ell &= \sqrt{\frac{4 \eta A}{N \pi}} = \dots = \underbrace{\frac{2}{\sqrt[4]{12}}}_k \sqrt{\frac{A}{N}}
\end{aligned}
$$

Así que un valor adecuado de $k$ es $2/ \sqrt[4]{12} \approx 1.075$. Añadimos un término de empaquetamiento para poder aplicar ajustes si es necesario:

$$
\begin{aligned}
    \ell &= \frac{k}{\alpha} \sqrt{\frac{A}{N}} \\
    \ell & \propto \frac{1}{\alpha}
\end{aligned}
$$

Por practícidad, $\alpha = 1$ a menos de que sea necesario otro valor.

## ¿Cuánto es $A$?
$A$ es el área disponible. Por comodidad, debería ser un círculo cuyo diámetro sea el lado más corto del recuadro que tenemos a la mano, por ejemplo, una pantalla de dimensiones $W \times H$ obtiene un diámetro $L$ de:

$$
L = \min{(W, H)}
$$

Aplicado al área $A$:

$$
A = \pi \left(\frac{L}{2}\right)^2 = \frac{\pi L^2}{4}
$$

Si lo aplicamos a la ecuación de $A_n$ y luego a la de $\ell$ obtenemos una forma adaptativa para disponer un grafo en una pantalla rectángular

## Optimizando los bucles
Dadas las fuerzas de repulsión y atracción descritas al principio, simplificamos:

$$
\begin{aligned}
    F_R (u) &= \sum F_R \\
    &= \sum \frac{\ell^2}{r} \hat{r} \\
    &= \ell^2 \sum \frac{\hat{r}}{r} \frac{r}{r} \\
    &= \ell^2 \sum \frac{\vec{r}}{r^2} \\
\end{aligned} \quad \begin{aligned}
    F_A (u) &= \sum F_A \\
    &= - \sum \frac{r^2}{\ell} \hat{r} \\
    &= - \frac{1}{\ell} \sum r^2 \frac{\vec{r}}{r} \\
    &= - \frac{1}{\ell} \sum r \vec{r} \\
\end{aligned}
$$

Formalizando:

$$
\begin{aligned}
    F_R (u) &= \ell^2 \sum_{u \neq v} \frac{\vec{u} - \vec{v}}{(\vec{u} - \vec{v})^2} \\
    F_A (u) &= - \frac{1}{\ell} \sum_{v \in N(u)} \sqrt{(\vec{u} - \vec{v})^2} \cdot (\vec{u} - \vec{v})
\end{aligned}
$$

Sabemos que $r$ es más difícil de calcular que $r^2$ pero el cálculo de atracción en aristas tiene complejidad algorítmica menor a la repulsión.
