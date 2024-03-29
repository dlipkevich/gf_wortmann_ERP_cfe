﻿#Область ОбработчикиСобытий

&Вместо("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	// регистр гф_ИсторияИзмененияБонусов
	Движения.гф_ИсторияИзмененияБонусов.Записывать = Истина;
	Для Каждого ТекСтрока Из Бонусы Цикл
		Движение = Движения.гф_ИсторияИзмененияБонусов.Добавить();
		Движение.Период = Дата;
		Движение.Организация = Организация;
		Движение.Сезон = Сезон;
		Движение.Бонус = ТекСтрока.Бонус;
		Движение.Значение = ТекСтрока.Значение;
		Движение.ПороговоеЗначение = ТекСтрока.ПороговоеЗначение;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти
