
# Slidebar

Slidebar é uma biblioteca em Lua para criar barras de progresso interativas com suporte a animações no MTA (Multi Theft Auto). Ela permite criar barras de progresso personalizáveis, com diferentes orientações, cores e efeitos visuais, além de permitir interações do usuário por meio do mouse.

## Instalação

Para usar o **Slidebar** no seu projeto, basta incluir o script e inicializar uma instância com as configurações desejadas.

## Funcionalidades

### Criar uma instância do Slidebar
```lua
local mySlider = Slidebar:new({
    width = 300,            -- Largura da barra
    height = 20,            -- Altura da barra
    radius = 10,            -- Raio das bordas arredondadas
    color = {               -- Definição das cores
        background = {
            default = {255, 255, 255, 255 * .5},
            hover = {255, 255, 255, 255 * .52}
        },
        bar = {
            default = {124, 177, 255, 255},
            hover = {124 - 10, 177 - 10, 255 - 10, 255}
        },
        circle = {
            default = {255, 255, 255, 255},
            hover = {255, 255, 255, 255} 
        }
    },
    orientation = "x",      -- Orientação da barra (x para horizontal, y para vertical)
    useCircle = true,       -- Usar círculo no slider
    useBackground = true,   -- Exibir fundo da barra
    defaultValue = 0.5,     -- Valor inicial do progresso
    smoothSpeed = 0.1       -- Velocidade da animação do progresso
})
```
- **`width`**: Largura da barra.
- **`height`**: Altura da barra.
- **`radius`**: Raio das bordas arredondadas da barra (opcional).
- **`color`**: Cores, tanto para o estado normal quanto para o estado "hover".
- **`orientation`**: Orientação da barra. Pode ser `"x"` para horizontal ou `"y"` para vertical.
- **`useCircle`**: Se `true`, exibe um círculo interativo no final da barra.
- **`useBackground`**: Se `true`, exibe o fundo da barra.
- **`defaultValue`**: Valor inicial do progresso (entre 0 e 1).
- **`smoothSpeed`**: Velocidade de transição do progresso (opcional).

Essa função verifica o movimento do mouse e ajusta o progresso da barra com base na interação do usuário.

### Renderizar a Slidebar (`render`)
```lua
mySlider:render(x, y, alpha)
```
- **`x`**: Posição X onde a barra será desenhada.
- **`y`**: Posição Y onde a barra será desenhada.
- **`alpha`**: Valor de opacidade para desenhar a barra (0 a 255).

Esta função desenha a barra no jogo, considerando a posição, as cores e o progresso atual.

### Obter e definir o progresso da Slidebar
```lua
mySlider:setOffset(0.75)  -- Define o progresso para 75%

local progress = mySlider:getOffset()  -- Obtém o valor do progresso
```
- **`setOffset(value)`**: Define o progresso da barra para um valor entre 0 e 1.
- **`getOffset()`**: Retorna o valor atual do progresso da barra.

### Eventos (Callbacks)
Você pode definir callbacks para ser executados quando o usuário interagir com a barra.

#### Evento `onSlide` (quando o progresso é alterado)
```lua
mySlider:onSlide(function(progress)
    print("Progresso alterado para: ", progress)
end)
```
- **`progress`**: Valor do progresso, entre 0 e 1.

#### Evento `onEnd` (quando a interação com a barra termina)
```lua
mySlider:onEnd(function(progress)
    print("Interação com a barra terminou. Progresso final: ", progress)
end)
```
- **`progress`**: Valor final do progresso após a interação.

### Exemplo

```lua
local slidebar = Slidebar:new({
    width = 300,
    height = 30,
    color = {
        background = {
            default = {255, 255, 255, 255 * .5},
            hover = {255, 255, 255, 255 * .52}
        },
        bar = {
            default = {124, 177, 255, 255},
            hover = {124 - 10, 177 - 10, 255 - 10, 255}
        },
        circle = {
            default = {255, 255, 255, 255},
            hover = {255, 255, 255, 255} 
        }
    },
    radius = 10,
    useCircle = true,
    orientation = "x",
    useBackground = true,
    defaultValue = 0.5,
    smoothSpeed = 0.05
})

-- Função chamada sempre que a barra for deslizada
slidebar:onSlide(function(progress)
    print("Progresso: " .. progress * 100 .. "%")  -- Exibe o progresso como percentual
end)

-- Função chamada quando o usuário termina de interagir com a barra
slidebar:onEnd(function(progress)
    print("Interação finalizada. Progresso final: " .. progress * 100 .. "%")  -- Exibe o progresso final
end)

-- Renderizar a barra na tela
addEventHandler("onClientRender", root, function()
    slidebar:render(100, 100, 255)  -- Desenha a barra na posição (100, 100) e com 255 de opacidade
end)

-- Atualizar a barra a cada movimento do cursor
addEventHandler("onClientRender", root, function()
    local x, y = getCursorPosition()
    slidebar:updateProgress(100, 100, 300, 30)  -- Atualiza o progresso baseado na posição do cursor
end)
```
