﻿
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	гф_СоздатьНовыеРеквизиты();
	гф_УстановитьВидимостьИДоступностьРеквизитов();
		
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы 

&НаКлиенте
Процедура гф_ХозяйственнаяОперацияПриИзмененииПосле(Элемент)
	
	гф_УстановитьВидимостьИДоступностьРеквизитов();
	гф_ОчиститьРеквизитыПриИзмененииХозОперации();
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ПартнерПриИзменении(Элемент)
	
	гф_ПартнерПриИзмененииНаСервере();
		
КонецПроцедуры

&НаКлиенте
Процедура гф_АдресДоставкиПриИзменении(Элемент)
	
	Если Не ЗначениеЗаполнено(Объект.гф_АдресДоставки) Тогда
		гф_АдресДоставкиПриИзмененииНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_АдресДоставкиОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	КонтрагентТКПоАдресу = гф_ПолучитьРеквизитВыбранногоЗначения(ВыбранноеЗначение, "ТК");
	Объект.гф_ТК = гф_ПолучитьРеквизитВыбранногоЗначения(КонтрагентТКПоАдресу, "Партнер");
	
КонецПроцедуры

&НаКлиенте
Процедура гф_АдресДоставкиНачалоВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	гф_АдресДоставкиНачалоВыбораНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура гф_АдресДоставкиАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	//а = гф_АдресДоставкиАвтоПодборНаСервере();
	//Если Не а Тогда;
	//	СтандартнаяОбработка = Ложь;
	//КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура гф_ТКНачалоВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ЗначениеОтбора = Новый Структура("Перевозчик", Истина);
	ПараметрыФормы = Новый Структура("Отбор", ЗначениеОтбора);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("гф_ОбработкаВыбораТК", ЭтотОбъект);
	
	ОткрытьФорму("Справочник.Партнеры.ФормаВыбора", ПараметрыФормы, ЭтотОбъект, , , , ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_ОчиститьРеквизитыПриИзмененииХозОперации()
	
	Если Объект.ХозяйственнаяОперация <> Перечисления.ХозяйственныеОперации.СписаниеТоваровПоТребованию Тогда
		 Объект.гф_Контрагент 		= Справочники.Контрагенты.ПустаяСсылка();
		 Объект.гф_АдресДоставки 	= Справочники.гф_АдресаДоставки.ПустаяСсылка();
		 Объект.гф_Партнер 			= Справочники.Партнеры.ПустаяСсылка();
		 Объект.гф_ТК 				= Справочники.Контрагенты.ПустаяСсылка();
	КонецЕсли;	
	
КонецПроцедуры	

&НаСервере
Процедура гф_УстановитьВидимостьИДоступностьРеквизитов()
	
	// Данные по "гф_Контрагент" не выводим на форму, а заполняем автоматически по реквизиту "гф_Партнер"
	Элементы.гф_АдресДоставки.Видимость 	= Объект.ХозяйственнаяОперация = 
										Перечисления.ХозяйственныеОперации.СписаниеТоваровПоТребованию;
	Элементы.гф_Партнер.Видимость 			= Объект.ХозяйственнаяОперация = 
										Перечисления.ХозяйственныеОперации.СписаниеТоваровПоТребованию;
	Элементы.гф_ТК.Видимость 				= Объект.ХозяйственнаяОперация = 
										Перечисления.ХозяйственныеОперации.СписаниеТоваровПоТребованию;
	
КонецПроцедуры	 

&НаСервере
Процедура гф_СоздатьНовыеРеквизиты()
	
	ТипПолеФормы = Тип("ПолеФормы");
		
	// Данные по "гф_Контрагент" не выводим на форму, а заполняем автоматически по реквизиту "гф_Партнер" 	
	НовоеПоле = Элементы.Добавить("гф_Партнер", ТипПолеФормы, Элементы.ГруппаДополнительно);
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Заголовок 	= "Клиент";
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_Партнер";
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_ПартнерПриИзменении");
	
	НовоеПоле = Элементы.Добавить("гф_АдресДоставки", ТипПолеФормы, Элементы.ГруппаДополнительно);
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_АдресДоставки";
	НовоеПоле.КнопкаВыбора 				= Истина;
	НовоеПоле.КнопкаВыпадающегоСписка 	= Истина;
	// Установка связи для отбора при открытии окна выбора адресов по контрагенту
	НоваяСвязь = Новый СвязьПараметраВыбора("Отбор.Владелец", "Объект.гф_Контрагент");
	НовыйМассив = Новый Массив();
	НовыйМассив.Добавить(НоваяСвязь);
	НовоеПоле.СвязиПараметровВыбора	= Новый ФиксированныйМассив(НовыйМассив);
	НовоеПоле.УстановитьДействие("ОбработкаВыбора", "гф_АдресДоставкиОбработкаВыбора");
	НовоеПоле.УстановитьДействие("НачалоВыбора", "гф_АдресДоставкиНачалоВыбора");
	НовоеПоле.УстановитьДействие("ПриИзменении", "гф_АдресДоставкиПриИзменении");
	НовоеПоле.УстановитьДействие("АвтоПодбор", "гф_АдресДоставкиАвтоПодбор");
	
	НовоеПоле = Элементы.Добавить("гф_ТК", ТипПолеФормы, Элементы.ГруппаДополнительно);
	НовоеПоле.Вид			= ВидПоляФормы.ПолеВвода;
	НовоеПоле.Видимость		= Истина;
	НовоеПоле.ПутьКДанным	= "Объект.гф_ТК";
	НовоеПоле.УстановитьДействие("НачалоВыбора", "гф_ТКНачалоВыбора");
		
КонецПроцедуры

&НаСервере
Процедура гф_ПартнерПриИзмененииНаСервере()
	
	гф_РаботаСАдресами.ПартнерПриИзмененииНаФормеДокумента(Объект);
	
КонецПроцедуры

&НаСервере
Процедура гф_АдресДоставкиПриИзмененииНаСервере()
	
	гф_РаботаСАдресами.АдресДоставкиПриИзмененииНаФормеДокумента(Объект)
	
КонецПроцедуры

&НаСервере
Процедура гф_АдресДоставкиНачалоВыбораНаСервере()
	
	гф_РаботаСАдресами.АдресДоставкиНачалоВыбораНаФормеДокумента(Объект)
	
КонецПроцедуры

&НаСервере
Функция гф_АдресДоставкиАвтоПодборНаСервере()
	
	Если ЗначениеЗаполнено(Объект.Партнер) И ЗначениеЗаполнено(Объект.Контрагент) Тогда
		
		Если Не Объект.Партнер = Объект.Контрагент.Партнер Тогда
			Возврат Ложь;	
		Иначе
			Возврат Истина;
		КонецЕсли;
		
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция гф_ПолучитьРеквизитВыбранногоЗначения(ВыбранноеЗначение, ИмяРеквизита)
	
    Возврат ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ВыбранноеЗначение, ИмяРеквизита);

КонецФункции

&НаКлиенте
Процедура гф_ОбработкаВыбораТК(ВыбранноеЗначение, ДополнительныеПараметры) Экспорт
	
	Объект.гф_ТК = ВыбранноеЗначение;	
	
КонецПроцедуры

#КонецОбласти