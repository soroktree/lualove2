-- Заранее инициализируем ссылки на имена классов, которые понадобятся,
-- ибо вышестоящие классы будут использовать часть нижестоящих.
local Ship, Bullet, Asteroid, Field, Xxx, Yyy

Ship = {}
-- У всех таблиц, метатаблицей которых является ship,
-- дополнительные методы будут искаться в таблице ship.
Ship.__index = Ship 

-- Задаём общее поле для всех членов класса, для взаимодействия разных объектов
Ship.type = 'ship'

-- Двоеточие - хитрый способ передать таблицу первым скрытым аргументом 'self'.
function Ship:new(field, x, y)
	-- Сюда, в качестве self, придёт таблица Ship.

	-- Переопределяем self на новый объект, self как таблица Ship больше не понадобится.
	self = setmetatable({}, self)

	-- Мы будем передавать ссылку на игровой менеджер, чтобы командовать им.
	self.field = field

	-- Координаты:
	self.x = x or 100 -- 100 - дефолт
	self.y = y or 100

	-- Текущий угол поворота:
	self.angle = 0
	
	-- И заполняем всё остальное:
	
	-- Вектор движения:
	self.vx = 0
	self.vy = 0

	
	-- Ускорение, пикс/сек:
	self.acceleration  = 200
	
	-- Скорость поворота:
	self.rotation      = math.pi
	
	-- Всякие таймеры стрельбы:
	self.shoot_timer = 0
	self.shoot_delay = 0.3
	
	-- Радиус, для коллизии:
	self.radius   = 30
		
	-- Список вершин полигона, для отрисовки нашего кораблика:
	self.vertexes = {0, -30, 30, 30, 0, 20, -30, 30}
	--[[ 
		Получится что-то такое, только чуть ровнее:
	  /\
	 /  \
	/_/\_\  
	]]
	
	-- Возвращаем свежеиспечёный объект.
	return self 
end

function Ship:update(dt)
	-- Декрементов нема, и инкрементов тоже, но это не очень страшно, правда?
	-- dt - дельта времени, промежуток между предыдущим и текущим кадром.
	self.shoot_timer = self.shoot_timer - dt
	
	
	-- Управление:
	
	-- "Если зажата кнопка и таймер истёк" - спавним новую пулю.
	if love.keyboard.isDown('x') and self.shoot_timer < 0 then
		self.field:spawn(Bullet:new(self.field, self.x, self.y, self.angle))

		-- И сбрасываем таймер, потому что мы не хотим непрерывных струй из пуль, 
		-- хоть это и забавно.
		self.shoot_timer = self.shoot_delay
	end
	
	if love.keyboard.isDown('left') then 

		-- За секунду, сумма всех dt - почти ровно 1,
		-- соответственно, за секунду, кораблик повернётся на угол Pi,
		-- полный оборот - две секунды, все углы в радианах.
		self.angle = self.angle - self.rotation * dt
	end

	if love.keyboard.isDown('right') then 
		self.angle = self.angle + self.rotation * dt
	end

	if love.keyboard.isDown('up') then 

		-- Вычисляем вектор ускорения, который мы приобрели за текущий кадр.
		local vx_dt = math.cos(self.angle) * self.acceleration * dt
		local vy_dt = math.sin(self.angle) * self.acceleration * dt

		-- Прибавляем к собственному вектору движения полученный.
		self.vx = self.vx + vx_dt
		self.vy = self.vy + vy_dt
	end

	-- Прибавляем к текущим координатам вектор движения за текущий кадр.
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt
	
	-- Пусть это и космос, но торможение в пространстве никто не отменял: 
	-- мы тормозим в классике, и тут должны.
	-- Торможение получается прогрессивным -
	-- чем быстрее двигаемся, тем быстрее тормозим.
	self.vx = self.vx - self.vx * dt
	self.vy = self.vy - self.vy * dt	
	
	--Тут уже проверки координат на превышение полномочий:
	--как только центр кораблика вылез за пределы экрана,
	--мы его тут же перебрасываем на другую сторону.
	local screen_width, screen_height = love.graphics.getDimensions()
	
	if self.x < 0 then
		self.x = self.x + screen_width
	end
	if self.y < 0 then
		self.y = self.y + screen_height
	end
	if self.x > screen_width then
		self.x = self.x - screen_width  
	end
	if self.y > screen_height then
		self.y = self.y - screen_height
	end

end

function Ship:draw()
	-- Говорим графической системе, 
	-- что всё следующее мы будем рисовать белым цветом.
	love.graphics.setColor(255,255,255)
	
	-- Вот сейчас будет довольно сложно, 
	-- грубо говоря, это трансформации над графической системой.
		
	-- Запоминаем текущее состояние графической системы.
	love.graphics.push()
	
	-- Переносим центр графической системы на координаты кораблика.
	love.graphics.translate (self.x, self.y)
	
	-- Поворачиваем графическую систему на нужный угол.
	-- Прибавляем Pi/2 потому, что мы задавали вершины полигона 
	-- острым концом вверх а не вправо, соответственно, при отрисовке
	-- нам нужно чуть довернуть угол чтобы скомпенсировать.
	love.graphics.rotate (self.angle + math.pi/2)
	
	-- Рендерим вершины полигона, line - контур, fill - заполненный полигон.
	love.graphics.polygon('line', self.vertexes)
	
	-- И, наконец, возвращаем топологию в исходное состояние 
	-- (перед love.graphics.push()).
	love.graphics.pop()
	
	-- Это было слегка сложно,
	-- рисовать кружочки/прямоугольнички значительно проще:
	-- там можно прямо указать координаты, и сразу получить результат
	-- и так мы будем рисовать астероиды/пули.

	-- Но на такой методике можно без проблем сделать игровую камеру.
	-- За полной справкой лучше залезть в вики, 
end

-- "Пушка! Они заряжают пушку! Зачем? А, они будут стрелять!"
-- Мы тоже хотим стрелять. 
-- Для стрельбы, нам необходимы пули, которыми мы будем стрелять.
-- Всё почти то же самое что у кораблика:

Bullet = {}
Bullet.__index = Bullet

-- Это - общие параметры для всех членов класса,
-- пули летят с одинаковой скоростью и имеют один тип,
-- поэтому можем выделить это в класс:
Bullet.type = 'bullet'
Bullet.speed = 300

function Bullet:new(field, x, y, angle)
  self = setmetatable({}, self)
	
	-- Аналогично задаём параметры
	self.field = field
	self.x      = x
	self.y      = y
	self.radius = 3

	-- время жизни
	self.life_time = 5
	
	-- Нам надо бы вычислить 
	-- вектор движения из угла поворота и скорости:
	self.vx = math.cos(angle) * self.speed
	self.vy = math.sin(angle) * self.speed
	-- Так как у объекта self нет поля speed, 
	-- поиск параметра продолжится в таблице под полем 
	-- __index у метатаблицы
	
	return self
end

function Bullet:update(dt)
	-- Управляем временем жизни:
	self.life_time = self.life_time - dt
	
	if self.life_time < 0 then
		-- У нас пока нет такого метода,
		-- но это тоже неплохо.
		self.field:destroy(self)
		return
	end
	
	-- Те же векторы
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	-- Пулям тоже не стоит улетать за границы экрана
	local screen_width, screen_height = love.graphics.getDimensions()
	
	if self.x < 0 then
		self.x = self.x + screen_width
	end
	if self.y < 0 then
		self.y = self.y + screen_height
	end
	if self.x > screen_width then
		self.x = self.x - screen_width
	end
	if self.y > screen_height then
		self.y = self.y - screen_height
	end
end

function Bullet:draw()
	love.graphics.setColor(255,255,255)
	
	-- Обещанная простая функция отрисовки.
	-- Полигоны, увы, так просто вращать не получится
	love.graphics.circle('fill', self.x, self.y, self.radius)
end

-- В кого стрелять? В мимопролетающие астероиды, конечно.
Asteroid = {}
Asteroid.__index = Asteroid
Asteroid.type = 'asteroid'

function Asteroid:new(field, x, y, size)
  self = setmetatable({}, self)
	
	-- Аналогично предыдущим классам.
	-- Можно было было бы провернуть наследование, 
	-- но это может быть сложно для восприятия начинающих.
	self.field  = field
	self.x      = x
	self.y      = y

	-- Размерность астероида будет варьироваться 1-N.
	self.size   = size or 3
		
	-- Векторы движения будут - случайными и неизменными.
	self.vx     = math.random(-20, 20)
	self.vy     = math.random(-20, 20)

	self.radius = size * 15 -- модификатор размера
	
	-- Тут вводится параметр здоровья,
	-- ибо астероид может принять несколько ударов
	-- прежде чем сломаться. Чуть рандомизируем для интереса.
	-- Чем жирнее астероид, тем потенциально жирнее он по ХП:
	self.hp = size + math.random(2)
	
	-- Пусть они будут ещё и разноцветными.
	self.color = {math.random(255), math.random(255), math.random(255)}
	return self
end

-- Тут сложный метод, поэтому выделяем его отдельно
function Asteroid:applyDamage(dmg)

	-- если урон не указан - выставляем единицу
	dmg = dmg or 1
	self.hp = self.hp - 1
	if self.hp < 0 then
		-- Подсчёт очков - самое главное
		self.field.score = self.field.score + self.size * 100
		self.field:destroy(self)
		if self.size > 1 then
			-- Количество обломков слегка рандомизируем.
			for i = 1, 1 + math.random(3) do
				self.field:spawn(Asteroid:new(self.field, self.x, self.y, self.size - 1))
			end
		end
		
		-- Если мы были уничтожены, вернём true, это удобно для некоторых случаев.
		return true
	end
end

-- Мы довольно часто будем применять эту функцию ниже
local function collide(x1, y1, r1, x2, y2, r2)
	-- Измеряем расстояния между точками по Теореме Пифагора:
  local distance = (x2 - x1) ^ 2 + (y2 - y1) ^ 2

	-- Коль это расстояние оказалось меньше суммы радиусов - мы коснулись.
	-- Возводим в квадрат чтобы сэкономить пару тактов на невычислении корней.
	local rdist = (r1 + r2) ^ 2
	return distance < rdist
end

function Asteroid:update(dt)

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	-- Астероиды у нас взаимодействуют и с пулями и с корабликом,
	-- поэтому можно запихнуть обработку взаимодействия в класс астероидов:
	for object in pairs(self.field:getObjects()) do
		-- Вот за этим мы выставляли типы.
		if object.type == 'bullet' then
			if collide(self.x, self.y, self.radius, object.x, object.y, object.radius) then
				self.field:destroy(object)
				-- А за этим - возвращали true.
				if self:applyDamage() then
					-- если мы были уничтожены - прерываем дальнейшие действия
					return
				end
			end
		elseif object.type == 'ship' then
			if collide(self.x, self.y, self.radius, object.x, object.y, object.radius) then
				-- Показываем messagebox и завершаем работу.
				-- Лучше выделить отдельно, но пока и так неплохо.
				
				local head = 'You loose!'
				local body = 'Score is: '..self.field.score..'\nRetry?'
				local keys = {"Yea!", "Noo!"}
				local key_pressed = love.window.showMessageBox(head, body, keys)
				-- Была нажата вторая кнопка "Noo!":
				if key_pressed == 2 then
					love.event.quit()
				end
				self.field:init()
				return
			end
		end
	end
	
	-- Границы экрана - закон, который не щадит никого!
	local screen_width, screen_height = love.graphics.getDimensions()
	
	if self.x < 0 then
		self.x = self.x + screen_width
	end
	if self.y < 0 then
		self.y = self.y + screen_height
	end
	if self.x > screen_width then
		self.x = self.x - screen_width
	end
	if self.y > screen_height then
		self.y = self.y - screen_height
	end
end

function Asteroid:draw()
	-- Указываем текущий цвет астероида:
	love.graphics.setColor(self.color)
	
	-- Полигоны, увы, так просто вращать не получится
	love.graphics.circle('line', self.x, self.y, self.radius)
end


-- Наконец, пишем класс который соберёт всё воедино:

Field = {}
Field.type = 'Field'
-- Это будет синглтон, создавать много игровых менеджеров мы не собираемся,
-- поэтому тут даже __index не нужен, ибо не будет объектов, 
-- которые ищут методы в этой таблице.

-- А вот инициализация/сброс параметров - очень даже пригодятся.
function Field:init()
	self.score   = 0

	-- Таблица для всех объектов на поле
	self.objects = {}

	local ship = Ship:new(self, 100, 200)
	print(ship)
	self:spawn(ship)
end


function Field:spawn(object)
	
	-- Это немного нестандартное применение словаря:
	-- в качестве ключа и значения указывается сам объект.
	self.objects[object] = object
end

function Field:destroy(object)

	-- Зато просто удалять.
	self.objects[object] = nil
end

function Field:getObjects()
	return self.objects
end

function Field:update(dt)

	-- Мы хотим создавать новые астероиды, когда все текущие сломаны.
	-- Сюда можно добавлять любые игровые правила.
	local asteroids_count = 0
	
	for object in pairs(self.objects) do
		-- Проверка на наличие метода
		if object.update then
			object:update(dt)
		end
		
		if object.type == 'asteroid' then
			asteroids_count = asteroids_count + 1
		end
	end
	
	if asteroids_count == 0 then
		for i = 1, 3 do
			-- Будем создавать новые на границах экрана
			local y = math.random(love.graphics.getHeight())
			self:spawn(Asteroid:new(self, 0, y, 3))
		end
	end
end

function Field:draw()
	for object in pairs(self.objects) do
		if object.draw then
			object:draw()
		end
	end
	love.graphics.print('\n  Score: '..self.score)
end


-- Последние штрихи: добавляем наши классы и объекты в игровые циклы:

function love.load()
	Field:init()
end


function love.update(dt)
	Field:update(dt)
end

function love.draw()
	Field:draw()
end