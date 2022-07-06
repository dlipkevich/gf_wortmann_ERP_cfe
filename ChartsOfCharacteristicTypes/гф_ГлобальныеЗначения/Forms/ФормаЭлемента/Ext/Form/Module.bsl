﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Элементы.Ключ.ОтображениеПредупрежденияПриРедактировании = ОтображениеПредупрежденияПриРедактировании.НеОтображать;
	КонецЕсли;
	
	Если Объект.ТипЗначения.Типы().Количество() > 1 Тогда
		Объект.ТипЗначения = Новый ОписаниеТипов("СправочникСсылка.Контрагенты");
		Объект.Значение = Элементы.Значение.ОграничениеТипа.ПривестиЗначение(Объект.Значение);
	КонецЕсли;
	вУстановитьВидимостьДоступность();
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Оповестить("ИзмененоГлобальноеЗначение", Объект.Ссылка);
КонецПроцедуры 

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
 
&НаСервере
Процедура вУстановитьВидимостьДоступность()
	
	Если ТолькоПросмотр Тогда
		Возврат;
	КонецЕсли;
	
	пРежимСписка = ВРег(Прав(Объект.Ключ, 7)) = "_СПИСОК";
	
	Если Не пРежимСписка Тогда
		Элементы.Список.ТолькоПросмотр = Истина;
	Иначе
		Элементы.Список.ТолькоПросмотр = Ложь;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

 &НаКлиенте
Процедура КлючПриИзменении(Элемент)
	вУстановитьВидимостьДоступность();
КонецПроцедуры

#КонецОбласти
