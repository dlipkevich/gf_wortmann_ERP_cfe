﻿
&НаКлиенте
Процедура АдресНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПараметрыАдреса = Новый Структура;
	ПараметрыАдреса.Вставить("ОткрытаПоСценарию");
	ПараметрыАдреса.Вставить("Представление", Объект.Адрес);
	ПараметрыАдреса.Вставить("Значение", Объект.Значение);
	ПараметрыАдреса.Вставить("ТипАдреса", "");
	ПараметрыАдреса.Вставить("ВидКонтактнойИнформации", 
		ПредопределенноеЗначение("Справочник.ВидыКонтактнойИнформации.ФактАдресКонтрагента"));
	
	ФормаВвода = ОткрытьФорму("Обработка.РасширенныйВводКонтактнойИнформации.Форма.ВводАдреса", ПараметрыАдреса, 
		ЭтотОбъект, ЭтотОбъект.УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ВыбранноеЗначение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		
		СтруктураКИ = ПолучитьСтруктуруКИ(ВыбранноеЗначение.Значение, ТипКИ);
		
		Объект.Адрес              = ВыбранноеЗначение.Представление;
		Объект.РегионКод          = СтруктураКИ.КодРегиона;
		Объект.РегионНаименование = СтруктураКИ.НаименованиеРегиона;
		Объект.Значение           = ВыбранноеЗначение.Значение;
		
		Модифицированность = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСтруктуруКИ(ИсточникКИ, ТипКИ)
	
	СтруктураКИ = УправлениеКонтактнойИнформациейСлужебный.JSONВКонтактнуюИнформациюПоПолям(ИсточникКИ, ТипКИ);
	СтруктураКИ.Вставить("КодРегиона", 0);
	СтруктураКИ.Вставить("НаименованиеРегиона", "");
	
	Если СтруктураКИ.Свойство("areaId") Тогда 
		ДанныеРегиона = ПолучитьКодРегиона(СтруктураКИ.areaId);
		СтруктураКИ.КодРегиона          = ДанныеРегиона.КодРегиона;
		СтруктураКИ.НаименованиеРегиона = ДанныеРегиона.НаименованиеРегиона;
	КонецЕсли;
	
	Возврат СтруктураКИ;
	
КонецФункции

&НаСервере
Функция ПолучитьКодРегиона(ИдРегиона)
	
	Результат = Новый Структура(
		"КодРегиона, НаименованиеРегиона", 0, "");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Рег.КодСубъектаРФ КАК КодСубъектаРФ,
	               |	Рег.Наименование КАК Наименование
	               |ИЗ
	               |	РегистрСведений.АдресныеОбъекты КАК Рег
	               |ГДЕ
	               |	Рег.Идентификатор = &Идентификатор";
	Запрос.УстановитьПараметр("Идентификатор", Новый УникальныйИдентификатор(ИдРегиона));
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Результат.КодРегиона          = Выборка.КодСубъектаРФ;
		Результат.НаименованиеРегиона = Выборка.Наименование;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ВерсионированиеОбъектов
	ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтаФорма);
	// Конец СтандартныеПодсистемы.ВерсионированиеОбъектов
	
	ТипКИ = Перечисления.ТипыКонтактнойИнформации.Адрес;
	
	ТекущийПользователь = Пользователи.ТекущийПользователь();
	ЕстьОграниченияКЛ = Справочники.КонтактныеЛицаПартнеров.гф_ЕстьОграниченияДоступаКонтакныхЛиц(ТекущийПользователь);
	Если ЕстьОграниченияКЛ Тогда
		ЗаполнитьРазрешенныеКЛ(ТекущийПользователь);
	КонецЕсли;
	
	УстановитьДоступностьКонтактногоЛица();
	
	УстановитьПараметрыВыбора();
	
	
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьРазрешенныеКЛ(ТекущийПользователь)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СправочникКонтактныеЛицаПартнеров.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.КонтактныеЛицаПартнеров КАК СправочникКонтактныеЛицаПартнеров
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ РАЗЛИЧНЫЕ
		|			КонтактныеЛицаПартнеровгф_ГруппыДоступа.Ссылка КАК Ссылка
		|		ИЗ
		|			(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|				ГруппыДоступаПользователи.Ссылка КАК Ссылка
		|			ИЗ
		|				Справочник.ГруппыДоступа.Пользователи КАК ГруппыДоступаПользователи
		|			ГДЕ
		// #wortmann { 
		// Сейчас пользователи находятся в составе группы пользователей 
		// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee3c16091b60dc
		// Галфинд_Домнышева 2023/08/24	
		//|				ГруппыДоступаПользователи.Пользователь = &ТекущийПользователь) КАК ГруппыДоступаПользователя
		|		(ГруппыДоступаПользователи.Пользователь = &ТекущийПользователь
		|				ИЛИ ГруппыДоступаПользователи.Пользователь В
		|					(ВЫБРАТЬ
		|						ГруппыПользователейСостав.Ссылка
		|					ИЗ
		|						Справочник.ГруппыПользователей.Состав КАК ГруппыПользователейСостав
		|					ГДЕ
		|						ГруппыПользователейСостав.Пользователь = &ТекущийПользователь)))
		|				КАК ГруппыДоступаПользователя
        // } #wortmann
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.КонтактныеЛицаПартнеров.гф_ГруппыДоступа КАК КонтактныеЛицаПартнеровгф_ГруппыДоступа
		|				ПО ГруппыДоступаПользователя.Ссылка = КонтактныеЛицаПартнеровгф_ГруппыДоступа.ГруппаДоступа) КАК РазрешенныеПоГруппамДоступа
		|		ПО СправочникКонтактныеЛицаПартнеров.Ссылка = РазрешенныеПоГруппамДоступа.Ссылка
		|ГДЕ
		|	СправочникКонтактныеЛицаПартнеров.Владелец = &Партнер";
	Запрос.УстановитьПараметр("ТекущийПользователь", ТекущийПользователь);
	Запрос.УстановитьПараметр("Партнер", Объект.Владелец.Партнер);
	МассивКЛ = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	РазрешенныеКЛ.ЗагрузитьЗначения(МассивКЛ);

КонецПроцедуры

&НаСервере
Процедура УстановитьПараметрыВыбора()
	
	// Установить отбор по владельцу при выборе контактных лиц
	НовыйПараметр = Новый ПараметрВыбора("Отбор.Владелец", Объект.Владелец.Партнер);
	
	НовыйМассив = Новый Массив();
	НовыйМассив.Добавить(НовыйПараметр);
	НовыеПараметры = Новый ФиксированныйМассив(НовыйМассив);
	
	Элементы.КонтактноеЛицо.ПараметрыВыбора = НовыеПараметры;
	
	Элементы.КонтактныеЛицаКонтактноеЛицо.ПараметрыВыбора = НовыеПараметры; // Галфинд_ДомнышеваКР_21_09_2023
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	// СтандартныеПодсистемы.УправлениеДоступом
	УправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
КонецПроцедуры

&НаКлиенте
Процедура ВладелецПриИзменении(Элемент)
	
	УстановитьДоступностьКонтактногоЛица();
	
	УстановитьПараметрыВыбора();
	
КонецПроцедуры

&НаСервере
Процедура УстановитьДоступностьКонтактногоЛица()
	
	Элементы.КонтактноеЛицо.Доступность = ЗначениеЗаполнено(Объект.Владелец);
	Элементы.КонтактноеЛицо.РежимПароля =  Ложь;
	Элементы.КонтактноеЛицо.КнопкаОткрытия = Истина;
	Если ЗначениеЗаполнено(Объект.КонтактноеЛицо)  
		И ЕстьОграниченияКЛ 
		И РазрешенныеКЛ.НайтиПоЗначению(Объект.КонтактноеЛицо) = Неопределено Тогда
		Элементы.КонтактноеЛицо.РежимПароля =  Истина;
		Элементы.КонтактноеЛицо.КнопкаОткрытия = Ложь;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура КонтактноеЛицоНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ГруппаДоступа = ПолучитьГруппуДоступаИзНастроек();
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ГруппаДоступа", ГруппаДоступа); 
	ПараметрыФормы.Вставить("РежимВыбора", Истина);
	
	ДанныеОтбора = Новый Структура("Владелец", ПолучитьПартнера(Объект.Владелец));
	ПараметрыФормы.Вставить("Отбор", ДанныеОтбора);
	
	ОткрытьФорму("Справочник.КонтактныеЛицаПартнеров.Форма.гф_ФормаВыбораОтбор", 
		ПараметрыФормы, Элементы.КонтактноеЛицо, 
		ЭтаФорма.УникальныйИдентификатор);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьГруппуДоступаИзНастроек()
	
	НастройкаГруппаДоступа = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту("Ключ", "ГруппаДоступаДляКонтрагентов");
	
	Если НЕ НастройкаГруппаДоступа.Пустая() Тогда
		Возврат НастройкаГруппаДоступа.Значение;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьПартнера(Контрагент)
	Возврат Контрагент.Партнер;
КонецФункции

&НаСервере
Процедура ЗаполнитьНаСервере()
	                     
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КонтактныеЛицаПартнеров.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.КонтактныеЛицаПартнеров КАК КонтактныеЛицаПартнеров
	|ГДЕ
	|	КонтактныеЛицаПартнеров.Ссылка = &Ссылка";
	Запрос.Параметры.Вставить("Ссылка",Объект.КонтактноеЛицо.Ссылка);
	Таб = Запрос.Выполнить().Выгрузить();
	КолТаб = Таб.Количество();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Организации.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Организации КАК Организации";
	ТабОрг = Запрос.Выполнить().Выгрузить();
	КолТабОрг = ТабОрг.Количество();
	//Индекс = 0;
	
	//Если Не КолТаб = 0 И Не КолТабОрг = 0 Тогда
	//	Объект.КонтактныеЛица.Очистить();
	//	Для Каждого Стр Из ТабОрг Цикл 
	//		НоваяСтрока = Объект.КонтактныеЛица.Добавить();
	//		Если Индекс = 0 Тогда
	//			НоваяСтрока.КонтактноеЛицо = Таб[0].Ссылка;
	//			НоваяСтрока.Организация    = Стр[0].Ссылка;
	//		Иначе
	//			НоваяСтрока.Организация    = Стр[0].Ссылка;
	//		КонецЕсли;
	//		Индекс = Индекс + 1;
	//	КонецЦикла;
	//КонецЕсли;
	НоваяСтрока = Объект.КонтактныеЛица.Добавить();
	НоваяСтрока.КонтактноеЛицо = Таб[0].Ссылка;
	НоваяСтрока.Организация    = ТабОрг;
КонецПроцедуры

&НаКлиенте
Процедура Заполнить(Команда)
	// ++ Галфинд_Домнышева_21_09_2023
	// По задаче пользователя не было необходимости добавлять команду, пользователю нужна была стандартная кнопка ТЧ.
	//ЗаполнитьНаСервере();
	// -- Галфинд_Домнышева_21_09_2023
КонецПроцедуры
