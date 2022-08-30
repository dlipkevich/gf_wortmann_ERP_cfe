﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка) 
	
	гф_СоздатьНовыеРеквизиты();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
			
	ОписаниеТиповУпаковочныйЛист		= Новый ОписаниеТипов("ДокументСсылка.УпаковочныйЛист");
	ОписаниеТиповЗаказКлиента  			= Новый ОписаниеТипов("ДокументСсылка.ЗаказКлиента");
	
	ДобавляемыеРеквизиты = Новый Массив;
	
	РеквизитФормы_гф_ЗаказКлиента			= Новый РеквизитФормы("гф_ЗаказКлиента",
										ОписаниеТиповЗаказКлиента, , "Заказ клиента", Истина);

	РеквизитФормы_гф_ИДКороба			= Новый РеквизитФормы("гф_ИДКороба",
										ОписаниеТиповУпаковочныйЛист, , "ИД короба", Истина);	
											
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ЗаказКлиента);
	ДобавляемыеРеквизиты.Добавить(РеквизитФормы_гф_ИДКороба);
		
	ИзменитьРеквизиты(ДобавляемыеРеквизиты);
	
	ТипПолеФормы = Тип("ПолеФормы");
		
	НовоеПоле = Элементы.Добавить("гф_ЗаказКлиента", ТипПолеФормы,
										Элементы.Товары);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.Товары.гф_ЗаказКлиента"; 	
		
	НовоеПоле = Элементы.Добавить("гф_ИДКороба", ТипПолеФормы,
										Элементы.Товары);
	
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.Товары.гф_IDКороба"; 
	
	Команда = Команды.Добавить("гф_ЗагрузитьИзВнешнегоФайла");
	Команда.Заголовок = "Загрузить из внешнего файла (ГФ)";
	Команда.Действие = "гф_ЗагрузитьИзВнешнегоФайла";
	
	НоваяКнопка = Элементы.Добавить("гф_ЗагрузитьИзВнешнегоФайла", Тип("КнопкаФормы"), Элементы.ТоварыЗаполнить);
	НоваяКнопка.вид = ВидКнопкиФормы.КнопкаКоманднойПанели;
	НоваяКнопка.ИмяКоманды = "гф_ЗагрузитьИзВнешнегоФайла";
		
КонецПроцедуры	

&НаКлиенте
Процедура гф_ЗагрузитьИзВнешнегоФайла(Команда)
	
	ХозяйственныеОперацииИмпорта = ХозяйственныеОперацииИмпорта();
	ХозяйственныеОперацииРаздельнойЗакупки = ХозяйственныеОперацииРаздельнойЗакупки();
	ПоступлениеПоРаздельнойЗакупке = (ХозяйственныеОперацииРаздельнойЗакупки.Найти(Объект.ХозяйственнаяОперация) <> Неопределено);
	ХозяйственнаяОперацияПриемНаКомиссию = (Объект.ХозяйственнаяОперация = ПредопределенноеЗначение("Перечисление.ХозяйственныеОперации.ПриемНаКомиссию"));
	
	ПараметрыЗагрузки = РаботаСТабличнымиЧастямиКлиент.ПараметрыЗагрузкиНоменклатуры();
	ПараметрыЗагрузки.Организация = Объект.Организация;
	ПараметрыЗагрузки.ЗаполнятьНоменклатуруПартнера = Объект.Партнер;
	ПараметрыЗагрузки.ЗагружатьЦены   = Истина;
	ПараметрыЗагрузки.ЗагружатьСуммы  = Истина;
	ПараметрыЗагрузки.ЗагружатьГТД    = ХозяйственныеОперацииИмпорта.Найти(Объект.ХозяйственнаяОперация) = Неопределено;
	ПараметрыЗагрузки.ЗагружатьСкидки = Не ХозяйственнаяОперацияПриемНаКомиссию;
	ПараметрыЗагрузки.ЦенаВключаетНДС    = Объект.ЦенаВключаетНДС;
	ПараметрыЗагрузки.НалогообложениеНДС = Объект.НалогообложениеНДС;
	ПараметрыЗагрузки.ДатаЗаполнения     = Объект.Дата;
	ПараметрыЗагрузки.ЭтоВозвратнаяТара  = Объект.ВернутьМногооборотнуюТару;

	Если ПоступлениеПоРаздельнойЗакупке Тогда
		ПараметрыЗагрузки.ПараметрыОтбора.Вставить("ТипНоменклатуры",
			НоменклатураКлиентСервер.ОтборПоТоваруМногооборотнойТареУслуге(Ложь));
	ИначеЕсли ХозяйственнаяОперацияПриемНаКомиссию Тогда
		ПараметрыЗагрузки.ПараметрыОтбора.Вставить("ТипНоменклатуры",
			НоменклатураКлиентСервер.ОтборПоТоваруМногооборотнойТаре(Ложь));
	КонецЕсли;

	ОповещениеОЗагрузке = Новый ОписаниеОповещения("ЗагрузитьИзВнешнегоФайлаЗавершение", ЭтотОбъект, "Товары");
	
	ОткрытьФорму("Обработка.гф_ЗагрузкаТоваровИзВнешнихФайлов.Форма.Форма", ПараметрыЗагрузки,
		ОповещениеОЗагрузке.Модуль, , , , ОповещениеОЗагрузке);
			
КонецПроцедуры	

#КонецОбласти